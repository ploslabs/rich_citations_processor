# Copyright (c) 2014 Public Library of Science

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

module RichCitationsProcessor
  module API

    class PLOS
      @httpclient = HTTPClient.new
      
      # Given the DOI of a PLOS paper, downloads the XML and parses it
      # Returns an XML document

      def self.get_nlm_document(doi)
        Nokogiri::XML.parse(@httpclient.get_content('http://www.plosone.org/article/fetchObjectAttachment.action',
                                                    { 'uri' => format('info:doi/%s', doi),
                                                      'representation' => 'XML' },
                                                    'Accept' => 'application/xml'))
      rescue HTTPClient::BadResponseError => resp
        raise unless resp.res.code == 500
        nil
      end

      def self.get_web_page(doi)
        doi = URI::DOI.new(doi, source:'internal') unless doi.is_a?(URI::Base)
        Nokogiri::HTML.parse(@httpclient.get_content(doi.full_uri, {}, 'Accept' => 'text/html'))
      end
    end
  end
end
