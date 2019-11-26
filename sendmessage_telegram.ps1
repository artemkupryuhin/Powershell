#Usage: sendmessage_telegram.ps1 -chat_id CHAT_ID -text 'TEXT' -markdown
function sendmessage_telegram {

param(
[string]$chat_id = $(Throw "'-chat_id' argument is mandatory"),
[string]$text = $(Throw "'-text' argument is mandatory"),
[switch]$markdown,
[switch]$nopreview
)

$token = "575268143:AAGB_8S-46armhCwwYhjDSjFfjBgnIX2HZU" #token from your bot
if($nopreview) { $preview_mode = "True" }
if($markdown) { $markdown_mode = "Markdown" } else {$markdown_mode = ""}

$payload = @{
    "chat_id" = $chat_id;
    "text" = $text
    "parse_mode" = $markdown_mode;
    "disable_web_page_preview" = $preview_mode;
}

Invoke-WebRequest `
    -Uri ("https://api.telegram.org/bot{0}/sendMessage" -f $token) `
    -Method Post `
    -ContentType "application/json;charset=utf-8" `
    -Body (ConvertTo-Json -Compress -InputObject $payload)

}

sendmessage_telegram  576450868 Привет, Лопух!