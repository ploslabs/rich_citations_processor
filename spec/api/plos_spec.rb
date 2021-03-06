# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

module RichCitationsProcessor

  RSpec.describe API::PLOS do

    describe '::get_jats_document' do

      it "should call the api" do
        stub_request(:get, 'http://www.plosone.org/article/fetchObjectAttachment.action?uri=info:doi/10.1234/5678&representation=XML').
              with(headers:{'Accept'=>'application/xml'}).
              to_return(body:'<root/>')
        result = API::PLOS.get_jats_document('10.1234/5678')
        expect(result).to be_a_kind_of(Nokogiri::XML::Node)
      end

      it "should eturn nil on a 500 error" do
        stub_request(:get, 'http://www.plosone.org/article/fetchObjectAttachment.action?uri=info:doi/10.1234/5678&representation=XML').
            to_return(status:500)
        result = API::PLOS.get_jats_document('10.1234/5678')
        expect(result).to be_nil
      end

    end

    describe '::get_web_page' do

      it "should call the api" do
        stub_request(:get, 'http://dx.doi.org/10.1234/5678').
            with(headers:{'Accept'=>'text/html'}).
            to_return(body:'<html/>')

        doi = URI::DOI.new('10.1234/5678')
        result = API::PLOS.get_web_page(doi)
        expect(result).to be_a_kind_of(Nokogiri::HTML::Document)
      end

      it "should call the api when passed a DOI with a url prefix" do
        stub_request(:get, 'http://dx.doi.org/10.1234/5678').
            with(headers:{'Accept'=>'text/html'}).
            to_return(body:'<html/>')

        doi = URI::DOI.new('http://dx.doi.org/10.1234/5678')
        result = API::PLOS.get_web_page(doi)
        expect(result).to be_a_kind_of(Nokogiri::HTML::Document)
      end

      it "should accept a plain doi" do
        stub_request(:get, 'http://dx.doi.org/10.1234/5678').
            with(headers:{'Accept'=>'text/html'}).
            to_return(body:'<html/>')

        result = API::PLOS.get_web_page('10.1234/5678')
        expect(result).to be_a_kind_of(Nokogiri::HTML::Document)
      end

    end

  end

end