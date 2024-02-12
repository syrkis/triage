local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Triage Logging"
obj.version = "0.1"
obj.author = "Noah Syrkis"
obj.homepage = "https://syrkis.com"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Path to the SQLite database
local sqlite3 = require("hs.sqlite3")
local dbPath  = os.getenv("HOME") .. "/data/triage/triage.db"

-- Function to log the active window's title and app name
local function logActiveWindowInfo()
    local window = hs.window.focusedWindow()
    if window then
        local title   = window:title()
        local appName = window:application():name()
        local db      = sqlite3.open(dbPath)
        if db then
            local appId, winId

            -- Insert the app name into the apps table if it doesn't exist (avoid sql injections)
            local appQueryTemplate = "SELECT id FROM applications WHERE name = '%s'"
            local appQuery = string.format(appQueryTemplate, appName)
            -- get the appId from the table if it exists (otherwise insert it)
            for row in db:rows(appQuery) do
                appId = row[1]
            end
            if not appId then
                local appInsertTemplate = "INSERT INTO applications (name) VALUES ('%s')"
                local appInsert = string.format(appInsertTemplate, appName)
                db:exec(appInsert)
                for row in db:rows(appQuery) do
                    appId = row[1]
                end
            end

            -- Insert the window title into the windows table if it doesn't exist (avoid sql injections)
            local winQueryTemplate = "SELECT id FROM windows WHERE title = '%s' AND application_id = %d"
            local winQuery = string.format(winQueryTemplate, title, appId)
            -- get the winId from the table if it exists (otherwise insert it)
            for row in db:rows(winQuery) do
                winId = row[1]
            end
            if not winId then
                local winInsertTemplate = "INSERT INTO windows (title, application_id) VALUES ('%s', %d)"
                local winInsert = string.format(winInsertTemplate, title, appId)
                db:exec(winInsert)
                for row in db:rows(winQuery) do
                    winId = row[1]
                end
            end

            -- insert the window into or increment consecutive column in logs if the window is the same as the last logged window
            local lastLogQuery = "SELECT window_id FROM logs ORDER BY timestamp DESC LIMIT 1"
            local lastLogWinId
            for row in db:rows(lastLogQuery) do
                lastLogWinId = row[1]
            end
            -- if the last logged window is the same as the current window, increment the consecutive column
            if lastLogWinId == winId then
                local consecutiveUpdateTemplate = "UPDATE logs SET consecutive = consecutive + 1 WHERE window_id = %d ORDER BY timestamp DESC LIMIT 1"
                local consecutiveUpdate = string.format(consecutiveUpdateTemplate, winId)
                db:exec(consecutiveUpdate)
            else
                local logInsertTemplate = "INSERT INTO logs (window_id) VALUES (%d)"
                local logInsert = string.format(logInsertTemplate, winId)
                db:exec(logInsert)
            end
            db:close()
        end
    end
end

local function logMoodSurvey()
end


function obj:start()
    -- Set up a timer to log data every 30 seconds
    if self.timer then
        self.timer:stop()
    end
    self.timer = hs.timer.doEvery(30, logActiveWindowInfo)
end

return obj
