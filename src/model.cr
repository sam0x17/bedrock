
class Bedrock::Base
  macro inherited
  end

  macro column(decl, **options)
    {% type = decl.type %}

    # Raise an exception if the delc type has more than 2 union types or if it has 2 types without nil
    # This prevents having a column typed to String | Int32 etc.
    {% if type.is_a?(Union) && (type.types.size > 2 || (type.types.size == 2 && !type.types.any?(&.resolve.nilable?))) %}
      {% raise "The column #{@type.name}##{decl.var} cannot consist of a Union with a type other than `Nil`." %}
    {% end %}

    {% column_type = (options[:column_type] && !options[:column_type].nil?) ? options[:column_type] : nil %}
    {% nilable = (type.is_a?(Path) ? type.resolve.nilable? : (type.is_a?(Union) ? type.types.any?(&.resolve.nilable?) : (type.is_a?(Generic) ? type.resolve.nilable? : type.nilable?))) %}
    
    @[Bedrock::Column(column_type: {{column_type}})]
    @{{decl.var}} : {{decl.type}} {% unless decl.value.is_a? Nop %} = {{decl.value}} {% end %}
  end
end

class TestModel < Bedrock::Base
  column id : String?
end
