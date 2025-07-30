require "openai"
require "io/console"

client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
ASSISTANT_ID = ENV.fetch("OPENAI_ASSISTANT_ID")

def ask_govuk_assistant(client, assistant_id, question)
  headers = { "OpenAI-Beta" => "assistants=v2" }

  # Create a new thread
  thread = client.beta.threads.create(
    request_options: { extra_headers: headers }
  )

  # Post the user's message
  client.beta.threads.messages.create(
    thread[:id],
    content: question,
    role: :user,
    request_options: { extra_headers: headers }
  )

  # Run the assistant
  run = client.beta.threads.runs.create(
    thread[:id],
    assistant_id: assistant_id,
    request_options: { extra_headers: headers }
  )

  # Poll for completion
  loop do
    run_status = client.beta.threads.runs.retrieve(
      run[:id],
      thread_id: thread[:id],
      request_options: { extra_headers: headers }
    )

    case run_status[:status]
    when :completed
      break
    when :failed
      raise "Run failed: #{run_status.inspect}"
    when :queued
      puts "Queued"
      sleep 1
    when :in_progress
      puts "In progress"
      sleep 1
    else
      raise "unrecognised status #{run_status[:status].inspect}"
    end
  end

  # Fetch the response
  messages = client.beta.threads.messages.list(thread[:id], request_options: { extra_headers: headers })
  messages.data.first.content.first.text.value
end

# --- CLI Loop ---

puts "GOV.UK Developer Docs Chat CLI (Ruby)"
puts "Ask a question or type 'exit' to quit."

loop do
  print "\n> "
  question = gets.strip
  break if question.downcase == "exit"

  begin
    response = ask_govuk_assistant(client, ASSISTANT_ID, question)
    puts "\n#{response}"
  rescue => e
    puts "\nError: #{e.message}"
  end
end

