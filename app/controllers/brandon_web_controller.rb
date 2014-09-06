require 'zip'

def run_brandontools(mode, names, file, images, other = {})
    opts = ''
    other.each {|param, value| opts += " -#{param}=#{value}"} 
    print "bin/brandontools -#{mode} -hide -names=#{names.join(',')} -E #{opts} \"#{file}\" #{images.join(' ')}"
    return `bin/brandontools -#{mode} -hide -names=#{names.join(',')} -E #{opts} \"#{file}\" #{images.join(' ')}`
end

class BrandonWebController < ApplicationController
  def mode3
  end
  
  def mode4
  end
  
  def mode0
  end
  
  def sprites
  end

  def generate
    files = {}
    params[:files].each do |f|
      files[f.tempfile.path] = f.original_filename
    end
    filenames = files.values.collect {|f| File.basename(f.gsub("\\", "/"), ".*")}
    array_name = params[:filename]
    width = params[:resize_width].to_i
    height = params[:resize_height].to_i
    mode = params[:mode]

    file = run_brandontools(mode, filenames, array_name, files.keys)

    @header = ''
    @impl = ''
    
    header_done = false
    in_preamble = true
    
    file.split(/\n/).each do |line|
      if line =~ /^Header:/
        next
      elsif line =~ /^Implementation:/ 
        header_done = true
        next
      end
      if line == "/*"
        in_preamble = true
      elsif line == "*/"
        in_preamble = false
      end
      if in_preamble
        files.each do |tmp, real|
            line.gsub!(tmp, real)
        end
      end
      @header += line + "\n" unless header_done
      @impl += line + "\n" if header_done
    end
    

    stringio = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry("#{array_name}.h")
        zio.write @header
        zio.put_next_entry("#{array_name}.c")
        zio.write @impl
    end
    stringio.rewind
    @binary_data = stringio.sysread
    
    render body: @binary_data, content_type: "application/zip"
  end
  
  def help
  end
end
