# Ajustes de Android después de "flutter create" (lo llama setup.bat).
$m = "android\app\src\main\AndroidManifest.xml"
$t = Get-Content $m -Raw
$t = $t -replace 'android:label="rim_coffee"', 'android:label="Rim Coffee"'
if ($t -notmatch 'android.permission.INTERNET') {
  $t = $t -replace '<application', "<uses-permission android:name=`"android.permission.INTERNET`"/>`n    <application"
}
Set-Content $m $t -NoNewline
$g = if (Test-Path "android\build.gradle.kts") { "android\build.gradle.kts" } else { "android\build.gradle" }
if (-not ((Get-Content $g -Raw) -match 'lintVital')) {
  Add-Content $g (Get-Content "tool\desactivar_lint.gradle.txt" -Raw)
}
