require 'csv'
require 'rspec'
require 'factory_bot'
require_relative '../parser.rb'
require 'spec_helper.rb' 
require 'tempfile'


# frozen_string_literal: true


describe "parsing" do

  # let(:test_in_file) do
  #   Tempfile.new('test_data').tap do |f|
  #     storms.each do |storm|
  #       f << storm
  #     end
    
  #     # storms.each do |line|
  #     #   f << line
  #     # end
   
  #     # f.close
  #   end
  # end

  # let(:storms) do
  #   [
  #     "AL112009,                IDA,     31,",
  #     "20091104, 0600,  , TD, 11.0N,  81.3W,  30, 1007,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, -999"
  #   ]
  # end

  # let!(:parser) do
  #   Parser.new(test_in_file)
  # end

  # p test_in_file
  #     parser = Parser.new(test_in_file) 

  describe "header_line?" do
    it "returns true for a header line" do
      
      # p parser
      line = "AL112009,                IDA,     31,"
      expect(Parser.header_line?(line)).to eq(true)
    end
    it "returns false for a best track entry line" do
      line = "20091104, 0600,  , TD, 11.0N,  81.3W,  30, 1007,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, -999"
      expect(header_line?(line)).to eq(false)
    end
  end
  
end
