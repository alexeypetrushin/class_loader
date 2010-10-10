require "#{File.expand_path(File.dirname(__FILE__))}/helper"
require "class_loader/file_system_adapter/camel_case_translator"
require "class_loader/file_system_adapter"
require "class_loader/chained_adapter"

describe ClassLoader::FileSystemAdapter do  
  before :all do
    @dir = prepare_spec_data __FILE__
  end
  
  before :each do        
    @fs_adapter = ClassLoader::FileSystemAdapter.new(ClassLoader::CamelCaseTranslator)    
    
    # Actually we are testing both ChainedAdapter and FileSystemAdapter
    @adapter = ClassLoader::ChainedAdapter.new
    @adapter.adapters << @fs_adapter
    
    @adapter.add_path "#{@dir}/common"    
  end
  
  after :all do
    clean_spec_data __FILE__
  end
  
  def write_file path, klass
    File.open("#{@dir}/#{path}", 'w'){|f| f.write "class #{klass}; end"}
  end
  
  it "exist?" do
    @adapter.exist?("SomeNamespace").should be_true
    @adapter.exist?("SomeNamespace::SomeClass").should be_true    
    @adapter.exist?("SomeNamespace::NonExistingClass").should be_false
  end
  
  it "should works with multiple class paths" do
    @adapter.add_path "#{@dir}/multiple_class_paths/path_a"
    @adapter.add_path "#{@dir}/multiple_class_paths/path_b"
      
    @adapter.exist?("ClassInPathA").should be_true
    @adapter.exist?("ClassInPathB").should be_true
  end
  
  it "read" do
    @adapter.read("SomeNamespace::SomeClass").should == "class SomeClass; end" 
  end
  
  it "to_file_path" do
    @adapter.to_file_path("NonExistingClass").should be_nil
    @adapter.to_file_path("SomeNamespace::SomeClass").should =~ /SomeNamespace\/SomeClass/
  end
  
  it "to_class_name" do
    @adapter.to_class_name("#{@dir}/non_existing_path").should be_nil
    @adapter.to_class_name("#{@dir}/common/SomeNamespace").should == "SomeNamespace"
    @adapter.to_class_name("#{@dir}/common/SomeNamespace/SomeClass").should == "SomeNamespace::SomeClass"
  end
  
  it "shouldn't allow to add path twice" do
    @adapter.clear
    @adapter.add_path "#{@dir}/common"
    lambda{@adapter.add_path "#{@dir}/common"}.should raise_error(/already added/)
  end
  
  describe "file watching" do  
    def changed_classes
      changed = []
      @adapter.each_changed_class{|c| changed << c}
      changed
    end
    
    it "each_changed_class shouldn't affect paths not specified for watching" do
      @adapter.add_path "#{@dir}/search_only_watched", false
      changed_classes.should == []        
      
      sleep(1) && write_file("watching/SomeClass.rb", "SomeClass")
      changed_classes.should == []
    end
      
    it "each_changed_class" do
      @adapter.add_path "#{@dir}/watching", true
      
      changed_classes.should == []        

      sleep(1) && write_file("watching/SomeClass.rb", "SomeClass")      
      changed_classes.should == ["SomeClass"]
    
      sleep(1) && write_file("watching/SomeClass.rb", "SomeClass")
      changed_classes.should == ["SomeClass"]
    end    
  end
end