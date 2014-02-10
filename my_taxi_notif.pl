#!/usr/bin/perl -w

require ESL;

my $con = new ESL::ESLconnection("localhost", "8021", "ClueCon");
my %appPort = (
  "BestTaxilQueue" => 30022,
);
$con->events("plain", "all");
while($con->connected()) {
  my $e = $con->recvEventTimed(100);
  #my $e = $con->recvEvent();
  if ($e) {
    my $name = $e->getHeader("Event-Name");
    if ($name =~ /CUSTOM/) {
      my $subclass = $e->getHeader("Event-Subclass");
      if ($subclass =~ /callcenter::info/) {
        my $ccaction = $e->getHeader("CC-Action");
        my $queue = $e->getHeader("CC-Member-CID-Name");
        my $callerPhone = $e->getHeader("CC-Member-CID-Number");
        my $calledPhone = $e->getHeader("Caller-Destination-Number");
        if (($ccaction =~ /bridge-agent-start/) && ($appPort{$queue})) {
          my $action = "start";
          printf "Header: [%s] = [%s]\n", $name, $subclass;
          printf "Data: [%s] => [%s] -- [%s]\n", $callerPhone, $calledPhone, $queue;
          #print $e->serialize();
          my $url_string = "http://foo-taxify.bar:$appPort{$queue}/notification/?calledPhone=$calledPhone&callerPhone=$callerPhone&type=$action";
          print "URL: $url_string\n";
          my $curl1=`curl "$url_string"`;
        }
        if (($ccaction =~ /bridge-agent-end/) && ($appPort{$queue})) {
          my $action = "stop";
          printf "Header: [%s] = [%s]\n", $name, $subclass;
          printf "Data: [%s] => [%s] -- [%s]\n", $callerPhone, $calledPhone, $queue;
          #print $e->serialize();
          my $url_string = "http://foo-taxify.bar:$appPort{$queue}/notification/?calledPhone=$calledPhone&callerPhone=$callerPhone&type=$action";
          print "URL:$url_string\n";
          my $curl2=`curl "$url_string"`;
        }
      }
    }
  }
}
