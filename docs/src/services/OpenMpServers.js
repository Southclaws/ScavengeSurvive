import Server from '../models/Server';

// Fetch open.mp servers, that contain the 'scavenge' (good enough, ok?) and return an array of Server instances
async function GetOpenMpServers() {
  try {
    const response = await fetch('https://api.open.mp/servers');
    const servers  = await response.json();

    return servers.filter(server => server.gm.toLowerCase().includes('scavenge')).map(server => {
      return new Server({
        online  : true,
        address : server.ip,
        name    : server.hn,
        language: server.la,
      });
    });
  } catch (error) {
    console.error('An error occurred while fetching open.mp servers:', error);
    return [];
  }
}

export default GetOpenMpServers;