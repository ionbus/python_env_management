wrong = b"cplager@gmail.com"

if commit.author_email == wrong:
    commit.author_name = b"Charles Lewis"
    commit.author_email = b"dev@ionbus.info"

if commit.committer_email == wrong:
    commit.committer_name = b"Charles Lewis"
    commit.committer_email = b"dev@ionbus.info"
