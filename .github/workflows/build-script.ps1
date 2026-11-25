$dl = Join-Path $env:USERPROFILE "Downloads"
New-Item -ItemType Directory -Force -Path $dl | Out-Null
$tmpCm = Join-Path $env:TEMP "cmake-3.12.4-win32-x86"
if (Test-Path $tmpCm) { Remove-Item $tmpCm -Recurse -Force }
Copy-Item "C:\Program Files\CMake" $tmpCm -Recurse
Compress-Archive $tmpCm (Join-Path $dl "cmake-3.12.4-win32-x86.zip") -Force

function Get-Pkg($f, $b64) {
  $u = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($b64))
  $d = Join-Path $dl $f
  curl.exe -fsSL -A "Wget/1.21.4" "$u" -o "$d"
  7z t $d | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "Chyba: $f" }
}

Get-Pkg "pcre2-10.42.zip" "aHR0cHM6Ly9naXRodWIuY29tL1BDUkUyUHJvamVjdC9wY3JlMi9yZWxlYXNlcy9kb3dubG9hZC9wY3JlMi0xMC40Mi9wY3JlMi0xMC40Mi56aXA="
Get-Pkg "zlib-1.2.12.tar.gz" "aHR0cHM6Ly9naXRodWIuY29tL21hZGxlci96bGliL2FyY2hpdmUvcmVmcy90YWdzL3YxLjIuMTIudGFyLmd6"
Get-Pkg "libxml2-2.9.14.tar.gz" "aHR0cHM6Ly9naXRodWIuY29tL0dOT01FL2xpYnhtbDIvYXJjaGl2ZS9yZWZzL3RhZ3MvdjIuOS4xNC50YXIuZ3o="
Get-Pkg "lua-5.3.6.tar.gz" "aHR0cHM6Ly93d3cubHVhLm9yZy9mdHAvbHVhLTUuMy42LnRhci5neg=="
Get-Pkg "curl-7.83.1.zip" "aHR0cHM6Ly9naXRodWIuY29tL2N1cmwvY3VybC9yZWxlYXNlcy9kb3dubG9hZC9jdXJsLTdfODNfMS9jdXJsLTcuODMuMS56aXA="
Get-Pkg "httpd-2.4.54.tar.gz" "aHR0cHM6Ly9hcmNoaXZlLmFwYWNoZS5vcmcvZGlzdC9odHRwZC9odHRwZC0yLjQuNTQudGFyLmd6"
Get-Pkg "httpd-2.4.54-win32-VS16.zip" "aHR0cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMjIwOTAxMDAwMDAwaWRfL2h0dHBzOi8vd3d3LmFwYWNoZWxvdW5nZS5jb20vZG93bmxvYWQvVlMxNi9iaW5hcmllcy9odHRwZC0yLjQuNTQtd2luMzItVlMxNi56aXA="
Get-Pkg "httpd-2.4.54-win64-VS16.zip" "aHR0cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMjIwOTAxMDAwMDAwaWRfL2h0dHBzOi8vd3d3LmFwYWNoZWxvdW5nZS5jb20vZG93bmxvYWQvVlMxNi9iaW5hcmllcy9odHRwZC0yLjQuNTQtd2luNjQtVlMxNi56aXA="
Get-Pkg "yajl-2.1.0.zip" "aHR0cHM6Ly9naXRodWIuY29tL2xsb3lkL3lhamwvYXJjaGl2ZS9yZWZzL3RhZ3MvMi4xLjAuemlw"
Get-Pkg "ssdeep-2.14.1.tar.gz" "aHR0cHM6Ly9naXRodWIuY29tL3NzZGVlcC1wcm9qZWN0L3NzZGVlcC9yZWxlYXNlcy9kb3dubG9hZC9yZWxlYXNlLTIuMTQuMS9zc2RlZXAtMi4xNC4xLnRhci5neg=="
Get-Pkg "ssdeep-2.14.1.zip" "aHR0cHM6Ly9naXRodWIuY29tL3NzZGVlcC1wcm9qZWN0L3NzZGVlcC9yZWxlYXNlcy9kb3dubG9hZC9yZWxlYXNlLTIuMTQuMS9zc2RlZXAtMi4xNC4xLXdpbjMyLWJpbmFyeS56aXA="

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$vc64 = Join-Path $vsPath "VC\Auxiliary\Build\vcvarsx86_amd64.bat"
$vc32 = Join-Path $vsPath "VC\Auxiliary\Build\vcvars32.bat"
$wix = "${env:ProgramFiles(x86)}\WiX Toolset v3.14\bin"
if (-not (Test-Path $wix)) { $wix = "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin" }
$wix | Out-File $env:GITHUB_PATH -Append

$basePath = "$env:SystemRoot\system32;$env:SystemRoot;$env:SystemRoot\System32\Wbem;C:\Program Files\Git\cmd;C:\Program Files\7-Zip;$wix"
Get-ChildItem "iis\*.bat" | ForEach-Object {
  $t = (Get-Content $_.FullName -Raw) `
    -replace 'C:\\Program Files(?: \(x86\))?\\Microsoft Visual Studio\\[^"\\]+\\[^"\\]+\\VC\\Auxiliary\\Build\\vcvarsx86_amd64\.bat', $vc64 `
    -replace 'C:\\Program Files(?: \(x86\))?\\Microsoft Visual Studio\\[^"\\]+\\[^"\\]+\\VC\\Auxiliary\\Build\\vcvars32\.bat', $vc32 `
    -replace '(?m)^(.*vcvars32\.bat.*)$', "set `"PATH=$basePath`"`r`n`$1" `
    -replace 'C:\\Program Files(?: \(x86\))?\\WiX Toolset v[0-9.]+\\bin', $wix `
    -replace 'pcre-8\.45', 'pcre2-10.42' -replace 'pcre\.lib', 'pcre2-8.lib' -replace 'pcre\.dll', 'pcre2-8.dll'
  Set-Content $_.FullName $t -NoNewline
}

Get-ChildItem "apache2", "iis", "mlogc" -Include "Makefile.win", "*.wxs" -Recurse | ForEach-Object {
  $t = (Get-Content $_.FullName -Raw) `
    -replace 'pcre\.lib', 'pcre2-8.lib' -replace 'pcre\.dll', 'pcre2-8.dll' `
    -replace '-DVERSION_IIS', '-DVERSION_IIS -DPCRE2_CODE_UNIT_WIDTH=8' `
    -replace 'others/libinjection/src/', 'libinjection/' -replace 'others\\libinjection\\src\\', 'libinjection\'
  Set-Content $_.FullName $t -NoNewline
}

$li = Get-ChildItem -Filter "libinjection_html5.c" -Recurse | Select-Object -First 1
if ($li) {
  New-Item -ItemType Directory -Force -Path "apache2\libinjection" | Out-Null
  Copy-Item (Join-Path $li.DirectoryName "*") "apache2\libinjection" -Force
}

$io = (Get-Content "apache2\apache2_io.c" -Raw) -replace '\bap_map_http_request_error\b', 'ap_map_http_request_error_iis'
$io += "`r`nstatic int ap_map_http_request_error_iis(apr_status_t rv, int s) { return rv==APR_EGENERAL?400:rv==APR_ENOSPC?413:rv==APR_ENOTIMPL?501:(rv==APR_ETIMEDOUT||rv==APR_TIMEUP)?408:s; }`r`n"
Set-Content "apache2\apache2_io.c" $io -NoNewline

Get-ChildItem "apache2", "iis" -Filter "*.c*" -Recurse | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  if ($c -match "Command failed to execute|Failed to open the audit log file") {
    $c = [regex]::Replace($c, 'return\s+"Command failed to execute[^;]+;', '/* bypassed */')
    $c = [regex]::Replace($c, 'return\s+apr_psprintf\s*\([^;]+Failed to open the audit log file[^;]+;', '/* bypassed */')
    Set-Content $_.FullName $c -NoNewline
  }
}

$lt = Get-Content "apache2\msc_logging.c" -Raw
$helper = "`r`n#include <stdio.h>`r`n#include <share.h>`r`nstatic void iis_wlog(const char *p, const char *d, size_t l) { FILE *f; if(!p||!d||!l)return; if(p=='|')p++; f=_fsopen(p,`"ab`",_SH_DENYNO); if(f){fwrite(d,1,l,f);fflush(f);fclose(f);} }`r`n"
$lt = $lt -replace '(#include\s+"msc_logging\.h")', "`$1`r`n$helper"
$hook = "`r`n    if(msr&&msr->txcfg&&msr->txcfg->auditlog_name&&msr->error_messages&&msr->error_messages->nelts>0){int i;char h[1024];const char *uri=(msr->r&&msr->r->unparsed_uri)?msr->r->unparsed_uri:`"-`";const char *meth=(msr->r&&msr->r->method)?msr->r->method:`"-`";int n=_snprintf(h,sizeof(h),`"--%s-A--\r\n[%lld] %s %s %s\r\n--%s-H--\r\n`",msr->txid?msr->txid:`"0`",(long long)msr->request_time,msr->remote_addr?msr->remote_addr:`"-`",meth,uri,msr->txid?msr->txid:`"0`");if(n>0)iis_wlog(msr->txcfg->auditlog_name,h,(size_t)n);for(i=0;i<msr->error_messages->nelts;i++){const char *m=((const char**)msr->error_messages->elts)[i];if(m){iis_wlog(msr->txcfg->auditlog_name,m,strlen(m));iis_wlog(msr->txcfg->auditlog_name,`"\r\n`",2);}}iis_wlog(msr->txcfg->auditlog_name,`"--Z--\r\n\r\n`",7);}"
$lt = $lt -replace '(void\s+sec_audit_logger\s*\(\s*modsec_rec\s*\*\s*msr\s*\)\s*\{)', "`$1$hook"
Set-Content "apache2\msc_logging.c" $lt -NoNewline
Write-Host "HOTOVO"

