require 'spec/spec_helper'

describe 'verbose logging' do
  def app
    Sinatra::Application
  end

  context 'top panel' do
    before do
      Post.make
    end

    it 'should 404 when there are no posts' do
      Post.destroy_all
      get('/')
      last_response.should_not be_ok
      last_response.status.should == 404
    end

    it 'should include Delicious bookmarks' do
      get('/')
      last_response.should be_ok
    end
  end
end