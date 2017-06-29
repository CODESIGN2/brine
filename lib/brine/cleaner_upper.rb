# cleaner_upper.rb -- clean up resources created during test run
#
# Will issue DELETE call for all tracked URLs which will normally be triggered in a hook.
#
# The present approach for this is to explicitly track created resources to which
# DELETE calls will be sent. Cleaning up of resources will be given some further attention
# in the future, but this functionality should be preserved.

class DeleteCommand
  attr_accessor :client, :path

  def initialize(client, path)
    @client = client
    @path = path
  end

  def cleanup
    begin
      @client.delete(@path)
    rescue
      # try again; TODO: Handle this more intentionally
      @client.delete(@path)
    end
  end
end

module CleanerUpper

  # HTTP client object used to issue DELETE calls
  # must support #delete(path)
  # to be injected by calling code
  def set_cleaning_client(client)
    @client = client
  end

  # Record resource to be cleaned
  def track_created_resource(path)
    created_resources << DeleteCommand.new(@client, path)
  end

  # Clean recorded resources
  # Expected to be called after test run
  def cleanup_created_resources
    created_resources.reverse.each {|it| it.cleanup }
  end

  private

  # Lazily initialized array of resources to remove
  def created_resources
    @created_resources ||= []
  end
end
