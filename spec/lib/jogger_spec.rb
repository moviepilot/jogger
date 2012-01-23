require_relative '../spec_helper'

class MyFakedPacerResult
  def some_existing_pacer_method
    :is_there
  end
end

class Jogger
  module NamedTraversals
    # This just multiplies the current traversal with x.
    # In a real use case you would take the current traversal,
    # traverse some more, and yield the result of your traversal.
    def self.test_traverser(current_traversal, x)
      (current_traversal || 1) * x
    end

    def self.no_argument_traverser(current_traversal)
      :worked
    end

    def self.method_missing_dummy(current_traversal)
      MyFakedPacerResult.new
    end

  end
end

describe Jogger do


  it "runs the named proc and replaces the current traversal with its result" do
    p = Jogger.new
    p.test_traverser(2)
    p.result.should == 2
  end

  it "allows for method chaining" do
    p = Jogger.new
    p.test_traverser(2).test_traverser(3)
    p.result.should == 6
  end

  it "doesn't allow to run a non existant traversal" do
    lambda do
      p = Jogger.new
      p.this_does_not_exist
    end.should raise_error("Unknown traversal this_does_not_exist")
  end

  it "works for traversals without arguments" do
    Jogger.new.no_argument_traverser.result.should == :worked
  end

  it "delegates method calls to the current traversal" do
    Jogger.new.method_missing_dummy.some_existing_pacer_method.result.should == :is_there
  end
end
