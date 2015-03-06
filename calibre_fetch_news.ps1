# Orignal Script https://gist.github.com/rogeliodh/1560289
# This is free and unencumbered shell script released into the public domain.
#

#Input Params
Param(
  #[Parameter(Mandatory=$True)]
  [string]$fileConfig ,
  #[Parameter(Mandatory=$True)]  
  [string]$recipe
)

# Check file config
if ($fileConfig.Trim().length -eq 0) {
	write "fileConfig is empty"
	exit;
}

if ($recipe.Trim().length -eq 0) {
	write "recipe is empty"
	exit;
}

if (-Not (Test-Path $fileConfig)) {
	write "$fileConfig doesn't exist!"
	exit;
}

#from http://tlingenf.spaces.live.com/blog/cns!B1B09F516B5BAEBF!213.entry
# Ini read
$ini = @{}
switch -regex -file $fileConfig
{
    "^\[(.+)\]$" {
        $section = $matches[1].Trim()
        $ini[$section] = @{}
    }
    "(.+)=(.+)" {
        $name,$value = $matches[1..2]
        $ini[$section.Trim()][$name.Trim()] = $value.Trim('"', " ")
    }
}

write "Section Selected: $recipe";
$currentRecipe = $ini[$recipe];

# Check outputdir
if (-Not (Test-Path $currentRecipe["outdir"])) {
	write "[$recipe]['outdir'] doesn't exist, try to make...";
    new-item $currentRecipe["outdir"] -itemtype directory
}

if (-Not (Test-Path $currentRecipe["outdir"])) {
	write "[$recipe]['outdir'] doesn't exist!";
    write $currentRecipe["outdir"];
	exit;
}

$datefile = Get-Date -format yyyy_MM_dd
$datestr = Get-Date -format yyyy/MM/dd

$outfile = "$($currentRecipe['outdir'])\$($currentRecipe['outprefix'])$($datefile).mobi";

write "Outfile: $($outfile)";

write "Fetching '$($currentRecipe["recipe"])' '$($outfile)' --output-profile '$($currentRecipe["outprofile"])'";
ebook-convert.exe $currentRecipe["recipe"] $outfile --output-profile $currentRecipe["outprofile"] --extract-to $currentRecipe["tempdir"];

# Change the author of the ebook from "calibre" to the current date. 
# I do this because sending periodicals to a Kindle Touch is removing
# the periodical format and there is no way to differentiate between
# two editions in the home screen. This way, the date is shown next 
# to the title.
# See http://www.amazon.com/forum/kindle/ref=cm_cd_t_rvt_np?_encoding=UTF8&cdForum=Fx1D7SY3BVSESG&cdPage=1&cdThread=Tx1AP36U78ZHQ1I
# and, please, email amazon (kindle-feedback@amazon.com) asking to add 
# a way to keep the peridiocal format when sending through @free.kindle.com 
# addresses
write "Setting date $($datestr) as author in $($outfile)"
ebook-meta.exe -a $datestr $outfile;

if ($currentRecipe['toemails'].length -gt 1) {
   foreach ($email in $currentRecipe['toemails'].Split(',')) { 
    $emailOK = $email.Trim();
    
    calibre-smtp.exe --attachment "$($outfile)" --relay "$($currentRecipe['smtp'])" --port "$($currentRecipe['port'])" --username "$($currentRecipe['user'])" --password "$($currentRecipe['passwd'])"  --encryption-method "TLS" --subject "$($currentRecipe['subjectprefix']) $datestr" "$($currentRecipe['from'])" "$($emailOK)" "$($currentRecipe['contentprefix']) $($datestr)";
   }
}

Remove-Item $outfile;
exit;