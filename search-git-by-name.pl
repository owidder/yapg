#!/opt/local/bin/perl

my $type = $ARGV[0]; # tree or blob?
my $pattern = $ARGV[1]; # filename to search for as regex

##################################################################
# find all objects (blobs, trees, commits, tags) in .git/objects
##################################################################

my @AllFiles = `find .git/objects/`;
my @AllSha1 = ();

for my $object (@AllFiles) {
	if($object =~ /([0-9a-f][0-9a-f])\/([0-9a-f]{38})/) {
		my $sha1 = $1 . $2;
		push(@AllSha1, $sha1);
	}
}

##################################################################
# find all trees containing the file
##################################################################

my $ctr = 0;
for my $foundSha1 (@AllSha1) {
	chomp $foundSha1;
	my $t = `git cat-file -t $foundSha1`;
	chomp $t;

	if($t eq $type) {

		my @Lines = `git cat-file -p $foundSha1`;
		for my $line (@Lines) {
			if($line =~ /$pattern/) {
				$ctr++;
				printf "found $type: %s\n", $foundSha1;
				if($type eq 'tree') {
					my $branchName = sprintf "found/%03s", $ctr;
					printf "created branch: %s\n", $branchName;
					#`git commit-tree $treeSha1 -m "found $pattern" | xargs -I{} git branch $branchName {}`;
				}
				break;
			}
		}
	}
}
