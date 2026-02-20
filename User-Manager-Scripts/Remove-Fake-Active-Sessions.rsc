{
    :local sessionData ({})
    :local activeIDs [/user-manager session find where active=yes]

    :log info "UM-Check: Starting stuck session scan..."

    # Step 1: Capture initial uptimes
    :foreach id in=$activeIDs do={
        :local currentUp [/user-manager session get $id uptime]
        # Using :tostr ensures the ID works as a valid array key
        :set ($sessionData->[:tostr $id]) $currentUp
    }

    # Step 2: Wait 5 seconds
    :delay 30s

    # Step 3: Re-check everyone
    :foreach id in=$activeIDs do={
        # Check if session still exists to avoid errors
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
}