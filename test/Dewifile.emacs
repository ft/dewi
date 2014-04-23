set_opt 'verbose', 'true';
register({ glob        => 'init.el',
           method      => 'copy',
           destination => '~/.emacs.d' });
end();
