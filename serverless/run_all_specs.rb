#!ruby
# frozen_string_literal: true

# This is the entry point for running all specs
require "minitest/autorun"
require_relative "./spec/spec_helper"
Dir.glob("./spec/*.spec.rb").each do |file|
  require File.expand_path(file, File.dirname(__FILE__))
end