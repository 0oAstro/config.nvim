-- Linux hosts are servers that the Mac reaches through Rex or SSH. A Rex
-- block on a server has no SSH variables, so the OS decides, not $SSH_*.
return {
  remote = vim.fn.has('linux') == 1 or vim.env.SSH_CONNECTION ~= nil,
}
