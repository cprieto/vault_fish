function fish_vault --argument ip username
  if not command -v vault > /dev/null
    echo
    echo (set_color red) "Error, vault is not installed!" (set_color normal)
    echo
    return 3
  end

  set -l vault_role "stepstone_default"

  if not set -q ip
    echo (set_color red) "Not enough arguments: You need to provide at least an IP" (set_color normal)
    echo
    echo "fish_vault IP [USERNAME]"
    echo
    return 1
  end

  set -l token_file "$HOME/.vault-token"
  vault login (cat $token_file) > /dev/null

  if test $status -eq 2 # it failed authentication with token, using ldap
    vault login -method=ldap username=(whoami)
  end

  if test $status -ne 0
    echo
    echo (set_color red) "Not authenticated, I have no idea what to do!" (set_color normal)
    echo
    return 2
  end

  if not test (set -q username)
    set username "stepstone"
  end

  vault ssh -role $vault_role -mode otp $username@$ip
end
