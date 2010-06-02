# bp-file is designed to be built via the bakery from its own source dir.
# A typical bakery order would look something like this:
#
# require "bakery/ports/bakery"
# topDir = File.dirname(File.expand_path(__FILE__));
# $order = {
#   :output_dir => File.join(topDir, "build"),
#   :packages => ["boost", "bp-file"],
#   :use_source => {
#        "bp-file"=>File.join(topDir, "bp-file")
#   },
#  :use_recipe => {
#        "bp-file"=>File.join(topDir, "bp-file", "recipe.rb")
#   }
#}
#
# Note that bp-file depends on boost

{
  :deps => [ 'boost' ],
  :configure => lambda { |c|
    boostIncDir = File.join(c[:output_inc_dir], "..", "boost")
    if (!File.directory?(boostIncDir)) 
      raise "boost filesystem must be build before bp-file"
    end
    btstr = c[:build_type].to_s.capitalize
    cmakeGen = nil
    # on windows we must specify a generator, we'll get that from the
    # passed in configuration
    cmakeGen = "-G \"#{c[:cmake_generator]}\"" if c[:cmake_generator]
    cmLine = "cmake -DCMAKE_BUILD_TYPE=\"#{btstr}\" #{c[:cmake_args]} " +
             " #{cmakeGen} " +
             " -DBUILD_DIR=\"#{c[:output_dir]}\""  +
             " \"#{c[:src_dir]}\"/src" 
    puts cmLine
    system(cmLine)
  },
  :build => {
    :Windows => lambda { |c|
      buildStr = c[:build_type].to_s.capitalize
      system("devenv bpfile.sln /Build #{buildStr}")
    },
    [ :MacOSX, :Linux ] => "make" 
  },
  :install => lambda { |c|
    # set up vars and dirs
    bt_str = c[:build_type].to_s

    # copy in header
    Dir.glob(File.join(c[:src_dir], "src", "api", "*.h")).each { |f|
      FileUtils.cp_r(f, c[:output_inc_dir], :verbose => true)
    }

    # copy in lib
    lib = File.join(c[:build_dir], "libbpfile_s.a")
    if c[:platform] == :Windows
      lib = File.join(c[:build_dir], bt_str, "bpfile_s.lib")
    end
    FileUtils.cp(lib, c[:output_lib_dir], :verbose => true)
  }
}
