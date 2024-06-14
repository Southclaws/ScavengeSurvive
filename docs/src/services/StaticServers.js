import Server from '../models/Server';
import servers from '../data/servers';

// Return an array of Server instances, converted from the servers array
function GetStaticServers() {
  return servers.map(server => 
    new Server({
      address : server.address,
      name    : server.name,
      language: server.language,
      links   : server.links
    })
  );
}

export default GetStaticServers;