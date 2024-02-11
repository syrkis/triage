-- DailySurvey.spoon/init.lua

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Psychoscope Survey"
obj.version = "0.1"
obj.author = "Noah Syrkis"
obj.homepage = "https://syrkis.com"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local sqlite3  = require("hs.sqlite3")
local dbPath   = os.getenv("HOME") .. "/data/psychoscope/psychoscope.db"
local filePath = os.getenv("HOME") .. "/Desktop/todo.txt"


-- Function to parse survey questions from the file
function parseSurvey()
  local file = io.open(filePath, "r")
  if not file then
      hs.alert.show("Failed to open todo.txt")
      return {}
  end
    local survey = {}
  local collect = false -- Flag to start collecting questions after the marker
  for line in file:lines() do
      if line == "// survey" then
          collect = true -- Start collecting lines as survey questions
      elseif collect then
          table.insert(survey, line)
      end
  end
  file:close() -- Ensure the file is closed after parsing
  return survey
end


-- Function to create a custom text prompt
function showQuestion(question)
  local button, answer = hs.dialog.textPrompt(question, "", "", "submit", "delay")
  return button, answer
end

function saveAnswers(questions, answers, db)
  -- No need to open the db connection here, passed as a parameter
  for i, question in ipairs(questions) do
    local answer = answers[i]
    -- Insert question if it is not already in the questions table
    local questionQueryTemplate = "SELECT id FROM questions WHERE question = ?"
    local questionStmt = db:prepare(questionQueryTemplate)
    questionStmt:bind_values(question)
    local questionId
    for row in questionStmt:nrows() do
      questionId = row.id
      break
    end
    questionStmt:finalize()

    if not questionId then
      local questionInsertStmt = db:prepare("INSERT INTO questions (question) VALUES (?)")
      questionInsertStmt:bind_values(question)
      questionInsertStmt:step()
      questionInsertStmt:finalize()
      questionId = db:last_insert_rowid()
    end

    -- Insert the answer into the answers table
    local answerInsertStmt = db:prepare("INSERT INTO answers (question_id, answer, timestamp) VALUES (?, ?, datetime('now'))")
    answerInsertStmt:bind_values(questionId, answer)
    answerInsertStmt:step()
    answerInsertStmt:finalize()
  end
end


-- Function to conduct the daily survey
function conductSurvey()
  -- Check current time
  local hour = os.date("*t").hour

  local db = sqlite3.open(dbPath)
  if not db then
    hs.alert.show("Failed to open database")
    return
  end

  -- Check if the survey has been completed today
  local date = os.date("%Y-%m-%d")
  local surveyDoneQuery = string.format("SELECT COUNT(*) as count FROM answers WHERE date(timestamp) = '%s'", date)
  local done = false
  for row in db:nrows(surveyDoneQuery) do
    if row.count > 0 then
      done = true
      break
    end
  end

  if done then
    db:close()
    return -- Exit if survey already done today
  end

  -- Assuming the survey hasn't been done, continue as before
  local survey    = parseSurvey()
  local questions = {}
  local answers   = {}
  for i, question in ipairs(survey) do
    local button, answer = showQuestion(question)
    if 'submit' == button then
      table.insert(questions, question)
      table.insert(answers, answer)
    else
      return
    end
  end
  saveAnswers(questions, answers, db)  -- Pass the database connection

  db:close() -- Close the database connection
end

function obj:start()
  -- Set up a timer to check every hour
  self.timer = hs.timer.doEvery(3600, function()
    local hour = os.date("*t").hour
      if hour >= 18 then
          -- Proceed to conduct the survey
          conductSurvey()
      end
  end)
  self.timer:start()
end

return obj
