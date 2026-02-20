:global umCheckRunning

:if ($umCheckRunning = true) do={
    :log error "UM-Check: Previous run still active. Skipping..."
} else={

:set umCheckRunning true

:local sessionData ({})
:local activeIDs [/user-manager session find where active=yes]

:log info "UM-Check: Starting stuck session scan..."

:foreach id in=$activeIDs do={
    :local currentUp [/user-manager session get $id uptime]
    :set ($sessionData->[:tostr $id]) $currentUp
}

:delay 10s

:foreach id in=$activeIDs do={
    :if ([:len [/user-manager session find where .id=$id]] > 0) do={

        :local oldUp ($sessionData->[:tostr $id])
        :local newUp [/user-manager session get $id uptime]
        :local suser [/user-manager session get $id user]

        :if ($oldUp = $newUp) do={
            :log warning ("UM-Check: Removing stuck session for user: " . $suser)
            /user-manager session remove $id
        }
    }
}

:log info "UM-Check: Scan complete."

:set umCheckRunning false
}
