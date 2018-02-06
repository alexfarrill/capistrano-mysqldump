module Capistrano
  module DSL
    module Mysqldump

      # converts a hash of options into a string.
      # drops falsey-valued keys.
      #
      # `{u: 'foo', 'single-transaction' => true, ignore-tables' => 'bar',  p: nil}`
      # => '-ufoo --ignore-tables=bar --single-transaction
      #
      def mysqldump_options_string(options = nil)
        options
        options.map do |k,v|
          next unless v
          used_value = v == true ? nil : v
          used_prefix, used_join = if k.length == 1
                                     ["-", '']
                                   else
                                     ["--", '=']
                                   end

          "#{used_prefix}#{[k, used_value].compact.join used_join}"
        end.compact.join ' '
      end

      # returns credential options for a given username and password
      # when given an empty or nil password, does not include p: in the returned hash
      def mysqldump_credential_options(username, password)
        {}.tap do |opts|
          opts[:u] = username
          opts[:p] = password if password == true || password && !password.empty?
        end
      end
    end
  end
end
