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

  module XMLUtilities
    extend self

    # Like Xml::Node.text but uses the same logic used by the other text
    def self.text(container)
      container.text.strip
      # self.text_before(container, nil).try(:strip)
    end

    # Adds spaces where nodes break and removes multiple spaces.
    # i.e. <first>J</first><last>Smith</last> becomes 'J Smith'
    def self.spaced_text(container)
      text_nodes = container.xpath('.//text()').map(&:text)
      text = text_nodes.join(" ")
      clean_text = text.squish
      clean_text
    end

    # Text up to a node
    def self.text_before(container, node)
      texts = []
      container = container.first if container.is_a?(Nokogiri::XML::NodeSet)
      breadth_traverse(container) do |n|
        return texts.join('').lstrip if n == node
        texts << n.text if n.text?
      end

      # If node is not found it is a failure
      node ? nil : texts.join('').lstrip
    end

    # Text after a node
    def self.text_after(container, node)
      text = ''
      found = false
      container = container.first if container.is_a?(Nokogiri::XML::NodeSet)

      depth_traverse(container) do |n|
        if found
          text += n.text if n.text?
        end
        if n == node
          found = true
        end
      end

      # If node is not found it is a failure
      found ? text.rstrip : nil
    end

    # Text between two nodes
    def self.text_between(first, last)
      return nil unless first.present?
      return first.text if first == last

      raise ArgumentError, "The first and last nodes must have the same parent" if last && last.parent != first.parent

      node = first
      text = node.text
      while node != last
        node = node.next
        break if node.nil?
        text += node.text
      end

      text
    end

    # Get the outermost section title
    def self.nearest(node, types)
      node = node.parent

      while node && defined?(node.parent)
        return node if types.include?(node.name.downcase)
        node = node.parent
      end

      return nil
    end

    def self.breadth_traverse(container, &block)
      all_children = container.xpath('.//node()')

      if block_given?
        yield(container)
        all_children.each(&block)
      else
        ( [container] + all_children.to_a ).each
      end

      # This is very slow
      # block.call(container)
      # container.children.each{ |j| breadth_traverse(j, &block) }
    end

    def self.depth_traverse(container, &block)
      container.traverse(&block)
    end

    # Optimize word counting by caching the iterator and not always going back to the beginning
    class WordCounter
      def initialize(container)
        @iterator   = XMLUtilities.breadth_traverse(container)
        @word_count = 0
      end

      def count_to(node)
        raise "Already Counted to end" unless @iterator

        while true do
          current = @iterator.next
          return @word_count if node == current
          @word_count += current.text.word_count if current.text?
        end
      end

      def count_to_end
        return @word_count unless @iterator

        while true do
          current = @iterator.next
          @word_count += current.text.word_count if current.text?
        end

      rescue StopIteration
        @iterator = nil
        @word_count
      end

    end

  end

end