require File.expand_path("../../../spec_helper", __FILE__)

describe "Warning.warn" do
  ruby_version_is "2.4" do
    it "complains" do
      -> {
        Warning.warn("Chunky bacon!")
      }.should complain("Chunky bacon!")
    end

    it "extends itself" do
      Warning.singleton_class.ancestors.should include(Warning)
    end

    it "has Warning as the method owner" do
      ruby_exe("p Warning.method(:warn).owner").should == "Warning\n"
    end

    it "can be overridden" do
      code = <<-RUBY
        $stdout.sync = true
        $stderr.sync = true
        def Warning.warn(msg)
          if msg.start_with?("A")
            puts msg.upcase
          else
            super
          end
        end
        Warning.warn("A warning!")
        Warning.warn("warning from stderr\n")
      RUBY
      ruby_exe(code, args: "2>&1").should == %Q[A WARNING!\nwarning from stderr\n]
    end

    it "is called by parser warnings" do
      Warning.should_receive(:warn)
      eval "{ key: :value, key: :value2 }"
    end
  end

  ruby_version_is "2.5" do
    it "is called by Kernel.warn" do
      Warning.should_receive(:warn)
      Kernel.warn("Chunky bacon!")
    end
  end
end
