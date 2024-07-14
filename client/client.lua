VORPcore = exports.vorp_core:GetCore() 
FeatherMenu = exports['feather-menu'].initiate()
BccUtils = exports['bcc-utils'].initiate()

local MailboxMenu, RegisterPage, MailActionPage, SendMessagePage, CheckMessagePage, SelectRecipientPage
local playermailboxId = nil
local recipientId = ''
local recipients = {}

function devPrint(msg)
    if Config.devMode then
        print(msg)
    end
end

RegisterNetEvent("isee-mail:checkMailNotification")
AddEventHandler("isee-mail:checkMailNotification", function()
    print("Received checkMailNotification event")  -- Debug print
    VORPcore.NotifyObjective(_U('NewMailNotification'), 5000)
    TriggerServerEvent("isee-mail:checkMail")
end)

function OpenMailboxMenu(hasMailbox)
    devPrint('LangDevPrint' .. tostring(hasMailbox))
    SendMessagePage = nil
    CheckMessagePage = nil
    SelectRecipientPage = nil
    if not playermailboxId then
        playermailboxId = _U('MailNotRegistered')
    end
    if not MailboxMenu then
        devPrint('LangDevPrint1')
        MailboxMenu = FeatherMenu:RegisterMenu('feather:mailbox:menu', {
            top = '5%',
            left = '5%',
            ['720width'] = '500px',
            ['1080width'] = '600px',
            ['2kwidth'] = '700px',
            ['4kwidth'] = '900px',
            style = {},
            contentslot = {
              style = {
                ['height'] = '450px',
                ['min-height'] = '250px'
              }
            },
            draggable = true
          }, {
            opened = function()
                DisplayRadar(false)
            end,
            closed = function()
                DisplayRadar(true)
            end,
        })
        devPrint('LangDevPrint2')
    end

    if not RegisterPage then
        devPrint('LangDevPrint3')
        RegisterPage = MailboxMenu:RegisterPage('register:page')
        RegisterPage:RegisterElement('header', {
            value = _U('RegisterPageHeader'),
            slot = "header",
            style = {}
        })
        
        RegisterPage:RegisterElement('button', {
            label = _U('MailboxRegistrationButton'),
            style = {
    
            }
        }, function()
            devPrint("Register Mailbox button pressed")
            TriggerServerEvent("isee-mail:registerMailbox")
            MailActionPage:RouteTo()
        end)
        devPrint("RegisterPage created")
    end

    if not MailActionPage then
        devPrint("Creating MailActionPage")
        MailActionPage = MailboxMenu:RegisterPage('mailaction:page')
        MailActionPage:RegisterElement('header', {
            value = _U('MailActionPageHeader'),
            slot = "header",
            style = {}
        })

        MailActionPage:RegisterElement('line', {
            slot = "header",
            style = {}
        })
        
        MailActionPage:RegisterElement('button', {
            label = _U('SendMailButton'),
            style = {}
        }, function(data)
            devPrint("Send Mail button pressed")
            TriggerServerEvent('isee-mail:getRecipients')
        end)
    
        MailActionPage:RegisterElement('button', {
            label = _U('CheckMailButton'),
            style = {}
        }, function()
            devPrint("Check Mail button pressed")
            TriggerServerEvent("isee-mail:checkMail")
        end)
        devPrint("MailActionPage created")
    end

    if hasMailbox then
        devPrint("Opening MailActionPage")
        MailboxMenu:Open({ startupPage = MailActionPage })
    else
        devPrint("Opening RegisterPage")
        MailboxMenu:Open({ startupPage = RegisterPage })
    end
end

RegisterNetEvent("isee-mail:mailboxStatus")
AddEventHandler("isee-mail:mailboxStatus", function(hasMailbox, mailboxId, playerName)
    devPrint("mailboxStatus event received. hasMailbox: " .. tostring(hasMailbox) .. " mailboxId: " .. tostring(mailboxId) .. " playerName: " .. playerName)
    playermailboxId = mailboxId
    playerName = playerName
    OpenMailboxMenu(hasMailbox)
end)

RegisterNetEvent("isee-mail:registerResult")
AddEventHandler("isee-mail:registerResult", function(success, message)
    devPrint("registerResult event received. success: " .. tostring(success) .. " message: " .. message)
    if success then
        RegisterPage:RegisterElement('button', {
            label = _U('MailActionsButton')
        }, function()
            MailActionPage:RouteTo()
        end)
    else
        devPrint("Mailbox registration failed: " .. message)
    end
end)

RegisterNetEvent("isee-mail:updateMailboxId")
AddEventHandler("isee-mail:updateMailboxId", function(newMailboxId)
    devPrint("updateMailboxId event received. newMailboxId: " .. tostring(newMailboxId))
    playermailboxId = newMailboxId
    if MailboxDisplay ~= nil then
        MailboxDisplay:update({
            value = _U('POBNumber') .. (playermailboxId or _U('MailNotRegistered'))
        })
    end
end)

RegisterNetEvent("isee-mail:receiveMails")
AddEventHandler("isee-mail:receiveMails", function(mails)
    devPrint("receiveMails event received. mails: " .. json.encode(mails))
    -- Notify the player that they received new mail
    if #mails > 0 then
        VORPcore.NotifyObjective(_U('NewMailNotification'), 5000)
    end
    OpenCheckMessagePage(mails)
end)

RegisterNetEvent("isee-mail:setRecipients")
AddEventHandler("isee-mail:setRecipients", function(data)
    recipients = data
    OpenSelectRecipientPage()
end)

function FormatDate(timestamp)
    return timestamp
end

function OpenCheckMessagePage(mails)
    devPrint("Opening CheckMessagePage")
    CheckMessagePage = MailboxMenu:RegisterPage('checkmail:page')
    CheckMessagePage:RegisterElement('header', {
        value = _U('ReceivedMessagesHeader'),
        slot = "header",
        style = {}
    })

    CheckMessagePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })
    
    for index, mail in ipairs(mails) do
        local fromName = mail.from_name or "Unknown"
        local subject = mail.subject or "No Subject"
        local buttonLabel = string.format("%d. " .. _U('mailFrom') .. "%s", index, fromName)
        
        CheckMessagePage:RegisterElement('button', {
            label = buttonLabel,
            slot = "content",
            style = {}
        }, function()
            OpenMessagePage(mail)
        end)
    end

    CheckMessagePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    CheckMessagePage:RegisterElement('button', {
        label = _U('BackButtonLabel'),
        slot = "footer",
        style = {},
    }, function()
        OpenMailboxMenu(true)
    end)

    CheckMessagePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    CheckMessagePage:RouteTo()
end

function OpenMessagePage(mail)
    devPrint("Opening MessagePage for mail: " .. json.encode(mail))
    local MessagePage = MailboxMenu:RegisterPage('message:page')

    MessagePage:RegisterElement('header', {
        value = _U('MessageContentHeader'),
        slot = "header",
        style = {}
    })

    MessagePage:RegisterElement('textdisplay', {
        value = mail.message or "No message content",
        style = {
            ['max-height'] = '200px',
            ['overflow-y'] = 'auto',
            ['overflow-x'] = 'hidden',
        }
    })

    MessagePage:RegisterElement('button', {
        label = _U('BackButtonLabel'),
        slot = "footer",
        style = {},
    }, function()
        OpenCheckMessagePage({mail})
    end)

    MessagePage:RegisterElement('button', {
        label = _U('DeleteMailButtonLabel'),
        slot = "footer",
        style = {},
    }, function()
        TriggerServerEvent("isee-mail:deleteMail", mail.id)
        TriggerServerEvent("isee-mail:checkMail")
    end)

    MessagePage:RouteTo()
end

function OpenSelectRecipientPage()
    devPrint("Creating SelectRecipientPage")
    SelectRecipientPage = MailboxMenu:RegisterPage('selectrecipient:page')
    SelectRecipientPage:RegisterElement('header', {
        value = _U('SelectRecipientHeader'),
        slot = "header",
        style = {}
    })

    SelectRecipientPage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for _, recipient in ipairs(recipients) do
        SelectRecipientPage:RegisterElement('button', {
            label = recipient.name,
            style = {},
        }, function()
            devPrint("Recipient selected: " .. recipient.name)
            recipientId = recipient.mailbox_id
            OpenSendMessagePage()
        end)
    end

    SelectRecipientPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    SelectRecipientPage:RegisterElement('button', {
        label = _U('BackButtonLabel'),
        slot = "footer",
        style = {},
    }, function()
        OpenMailboxMenu(true)
    end)

    SelectRecipientPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    SelectRecipientPage:RouteTo()
end

function OpenSendMessagePage()
    devPrint("Creating SendMessagePage")
    SendMessagePage = MailboxMenu:RegisterPage('sendmail:page')
    SendMessagePage:RegisterElement('header', {
        value = _U('SendPigeonHeader'),
        slot = "header",
        style = {}
    })

    local mailMessage = ''
    local subjectTitle = ''

    SendMessagePage:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    SendMessagePage:RegisterElement('button', {
        label = _U('SelectRecipientButton'),
        style = {
        }
    }, function(data)
        devPrint("Select Recipient button pressed")
        OpenSelectRecipientPage()
    end)

    SendMessagePage:RegisterElement('input', {
        persist = false,
        label = _U('SubjectPlaceholder'),
        placeholder = _U('SubjectPlaceholder'),
        style = {}
    }, function(data)
        subjectTitle = data.value
    end)

    SendMessagePage:RegisterElement('textarea', {
        placeholder = _U('MessagePlaceholder'),
        rows = "6",
        --cols = "45",
        resize = true,
        style = {}
    }, function(data)
        mailMessage = data.value
    end)
    
    SendMessagePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    SendMessagePage:RegisterElement('button', {
        label = _U('SendMailButton'),
        slot = "footer",
        style = {},
    }, function(data)
        devPrint("recipientId: " .. recipientId .. " subjectTitle: " .. subjectTitle .. " mailMessage: " .. mailMessage)
        TriggerServerEvent("isee-mail:sendMail", recipientId, subjectTitle, mailMessage)
        if Config.SendPigeon then
            TriggerEvent('spawnPigeon') 
        end
        OpenMailboxMenu(true)
    end)

    SendMessagePage:RegisterElement('button', {
        label = _U('BackButtonLabel'),
        slot = "footer",
        style = {},
    }, function()
        OpenMailboxMenu(true)
    end)

    SendMessagePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    devPrint("SendMessagePage created")

    SendMessagePage:RouteTo()
end

RegisterNetEvent('spawnPigeon')
AddEventHandler('spawnPigeon', function()
    devPrint("spawnPigeon event received")
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local spawnCoords = vector3(playerCoords.x + 0.0, playerCoords.y + 0.0, playerCoords.z + 0.0)
    local model = GetHashKey('A_C_Pigeon')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
    local pigeon = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false, true, true)
    TaskFlyAway(pigeon)
    SetModelAsNoLongerNeeded(model)
end)

Citizen.CreateThread(function()
    local PromptGroup = BccUtils.Prompt:SetupPromptGroup()
    local mailboxPrompt = nil

    function registerMailboxPrompt()
        if mailboxPrompt then
            mailboxPrompt:DeletePrompt()
        end
        mailboxPrompt = PromptGroup:RegisterPrompt(_U('OpenMailBox'), 0x4CC0E2FE, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    end

    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearMailbox = false

        for _, location in pairs(Config.MailboxLocations) do
            if Vdist(playerCoords, location.coords.x, location.coords.y, location.coords.z) < 2 then
                nearMailbox = true
                break
            end
        end

        if nearMailbox then
            if not mailboxPrompt then
                registerMailboxPrompt()
            end
            PromptGroup:ShowGroup(_U('NearMailbox'))

            if mailboxPrompt:HasCompleted() then
                devPrint(_U('MailboxPromptCompleted'))
                TriggerServerEvent("isee-mail:checkMailbox")
                registerMailboxPrompt()
            end
        else
            if mailboxPrompt then
                mailboxPrompt:DeletePrompt()
                mailboxPrompt = nil
            end
        end
    end
end)

Citizen.CreateThread(function()
    for _, location in ipairs(Config.MailboxLocations) do
        local x, y, z = table.unpack(location.coords)
        local blip = BccUtils.Blip:SetBlip('Posta', 'blip_ambient_delivery', 0.2, x, y, z)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for _, playerId in ipairs(GetPlayers()) do
            TriggerEvent('isee-mail:updateMailboxInfo', playerId)
        end
    end
end)

function GetPlayers()
    local players = {}
    for i = 0, 256 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end
    return players
end
