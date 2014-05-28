require 'rspec'
require 'active_record'
require 'active_support'

require_relative '../lib/seria'

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    encoding: 'utf8',
    database: ":memory:")

Time.zone = "Berlin"
describe Seria::DefaultConverter do

  examples = {
      1 => Fixnum,
      true => TrueClass,
      false => FalseClass,
      1.0 => Float,
      1.to_d => BigDecimal,
      nil => NilClass,
      "cool" => String,
      Date.yesterday => Date,
      Time.now.round => Time,
      Time.now.round.to_datetime => DateTime,
      #Time.zone.at(Time.now.to_i) => ActiveSupport::TimeWithZone
  }

  examples.each do |value, klass|
    describe :klass do
      it "should return class #{klass} when no type given" do
        Seria::DefaultConverter.new(value, nil).klass.should == klass.to_s
      end
    end

    describe :convert do
      it "should convert #{value} from String to #{klass}" do
        Seria::DefaultConverter.new(value.to_s, klass.to_s).convert.class.should == klass
      end
      it "should return #{klass} to it's original value" do
        val = Seria::DefaultConverter.new(value.to_s, klass.to_s).convert
        val.class.should == klass
        val.should == value
      end
      it "returns original #{klass} when already converted" do
        val = Seria::DefaultConverter.new(value, klass.to_s).convert
        val.class.should == klass
        val.should == value
      end
      it "returns original #{klass} when no type given" do
        val = Seria::DefaultConverter.new(value, nil).convert
        val.class.should == klass
        val.should == value
      end
    end

  end

end