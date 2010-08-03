#
# puppetmaster MUST be restarted when this file is updated
#
# The pop value denotes the location of the host. This can be useful
# when dealing with multiple sites as well as with pre-production.
#
# The form is hostname.pop.yourdomain.tld
#
Puppet::Parser::Functions.newfunction('pop',:type => :rvalue) do
    default = "broken"
    valid = %w{dfw1 lab0 sea0}
    pop = nil

    # Try to find a valid pop name in the fully-qualified hostname
    if hostname = lookupvar("fqdn") and hostname != :undefined
        pop = hostname.split(".")[1]
        # Reset the pop name if the derived name is not in our valid list
        pop = nil unless valid.include?(pop)
    end

    # If we still don't have a value...
    unless pop
        # See if it was set manually via a fact or something like that
        if popfact = lookupvar("pop") and popfact != :undefined
            pop = popfact
        end
    end

    # If we still don't have a valid value, use the default
    pop = default unless pop and valid.include?(pop)
 
    # And provide it to our discerning customers
    pop
end
