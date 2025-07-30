require "fileutils"

SOURCE_DIR = ENV.fetch("DEVELOPER_DOCS_DIR")
OUTPUT_DIR = "doc_chunks"
MAX_CHUNK_SIZE = 50_000  # Approx 50k characters per chunk

FileUtils.mkdir_p(OUTPUT_DIR)

chunk = ""
chunk_index = 1
current_size = 0

def write_chunk(index, content)
  filename = File.join(OUTPUT_DIR, "docs_chunk_#{index}.txt")
  File.write(filename, content)
  puts "✅ Wrote #{filename} (#{content.length} characters)"
end

Dir.glob("#{SOURCE_DIR}/**/*.md").sort.each do |file_path|
  content = File.read(file_path)
  header = "# #{File.basename(file_path)}\n\n"
  full_text = header + content + "\n\n"

  if current_size + full_text.length > MAX_CHUNK_SIZE
    write_chunk(chunk_index, chunk)
    chunk_index += 1
    chunk = ""
    current_size = 0
  end

  chunk << full_text
  current_size += full_text.length
end

# Write final chunk
write_chunk(chunk_index, chunk) unless chunk.empty?
