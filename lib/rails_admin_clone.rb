module RailsAdmin
  module Config
    module Actions
      class Clone < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :visible? do
          true
        end

        register_instance_option :member do
          true
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :link_icon do
          'icon-copy'
        end

        register_instance_option :controller do
          Proc.new do
            object_class = @object.class.to_s.singularize.classify.constantize
            new_attributes = RailsAdmin::Config::Actions::Clone.reset_ids(@object.attributes)
            copy_object = object_class.new(new_attributes)
            if copy_object.save
              flash[:notice] = "You cloned a #{@object.class}."
            else
              flash[:error] = "Error: #{copy_object.errors.full_messages.to_sentence}"
            end
            redirect_to back_or_index
          end
        end


        def self.reset_ids(attributes)
          attributes.each do |key, value|
            if key == "_id" and value.is_a?(Moped::BSON::ObjectId)
              attributes[key] = Moped::BSON::ObjectId.new
            elsif value.is_a?(Hash) or value.is_a?(Array)
              attributes[key] = reset_ids(value)
            end
          end
          attributes
        end
      end
    end
  end
end