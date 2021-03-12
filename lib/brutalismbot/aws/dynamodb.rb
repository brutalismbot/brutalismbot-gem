require "brutalismbot/aws/dynamodb/client"

class Hash
  def to_dynamodb
    self.map { |k,v| [ k.to_s, self.to_dynamodb_item(v) ] }.to_h
  end

  def from_dynamodb
    self.map { |k,v| [ k.to_s, self.from_dynamodb_item(v) ] }.to_h
  end

  private

  def to_dynamodb_item(item)
    case item
    when Hash       then { "M"    => item.map { |k,v| [ k, self.to_dynamodb_item(v) ] }.to_h }
    when Array      then { "L"    => item.map { |x| self.to_dynamodb_item(x) } }
    when Numeric    then { "N"    => item.to_s }
    when String     then { "S"    => item.to_s }
    when Symbol     then { "S"    => item.to_s }
    when TrueClass  then { "BOOL" => item }
    when FalseClass then { "BOOL" => item }
    else raise "Unknown type: #{ self.class }"
    end
  end

  def from_dynamodb_item(item)
    item.map do |type,val|
      case type.to_s
      when "M"    then val.from_dynamodb
      when "L"    then val.map { |x| self.from_dynamodb_item(x) }
      when "N"    then val.to_f
      when "S"    then val
      when "BOOL" then val
      else raise "Unknown type: #{ type.to_s.inspect }"
      end
    end.first
  end
end
