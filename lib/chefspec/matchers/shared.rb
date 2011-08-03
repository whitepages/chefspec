# Given a resource return the unqualified type it is
#
# @param [String] resource A Chef Resource
# @return [String] The resource type
def resource_type(resource)
  resource.resource_name.to_s
end

# Define simple RSpec matchers for the product of resource types and actions
#
# @param [Array] actions The valid actions - for example [:create, :delete]
# @param [Array] resource_types The resource types
# @param [Symbol] name_attribute The name attribute of the resource types
def define_resource_matchers(actions, resource_types, name_attribute)
  actions.product(resource_types).flatten.each_slice(2) do |action, resource_type|
    RSpec::Matchers.define "#{action}_#{resource_type}".to_sym do |name|
      match do |chef_run|
        accepted_types = [resource_type.to_s]
        accepted_types << 'template' if action.to_s == 'create' and resource_type.to_s == 'file'
        chef_run.resources.any? do |resource|
          accepted_types.include? resource_type(resource) and resource.send(name_attribute) == name and
              resource.action.to_s.include? action.to_s
        end
      end
      failure_message_for_should do |actual|
        "No #{resource_type} resource named '#{name}' with action :#{action} found."
      end
      failure_message_for_should_not do |actual|
        "Found #{resource_type} resource named '#{name}' with action :#{action} that should not exist."
      end
    end
  end
end