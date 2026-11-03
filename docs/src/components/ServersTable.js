import React, { useEffect, useState } from 'react';
import GetOpenMpServers from '../services/OpenMpServers';
import GetStaticServers from '../services/StaticServers';

function ServersTable() {
  const [serverData, setServerData] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);
  const [loadingMessage, setLoadingMessage] = useState('');

  const processLinks = links => {
    if (!links) return;

    return Object.entries(links).map(([displayText, link], index) => {
      // If it's a Discord link, display the invite code
      const url = new URL(link);
      if (url.hostname.includes('discord')) {
        const pathParts = url.pathname.split('/');
        displayText = pathParts[pathParts.length - 1];
      } else {
        // Capitalize the first letter of the display text (because it's a key, so it's likely to be lowercase)
        displayText = displayText.charAt(0).toUpperCase() + displayText.slice(1);
      }

      return <a key={index} href={link}>{displayText}</a>;
    });
  };

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setLoadingMessage('Retrieving "open.mp" servers...');

        const openMpServers = await GetOpenMpServers();

        // Preserve curated links while preferring metadata from open.mp.
        const staticServers = GetStaticServers();
        for (const server of openMpServers) {
          server.links = staticServers.find(entry => entry.address === server.address)?.links;
        }
        const servers = [...openMpServers, ...staticServers.filter(staticServer => !openMpServers.some(server => server.address === staticServer.address))];

        // Randomize the order of the servers, to avoid any bias
        servers.sort(() => Math.random() - 0.5);

        for (const server of servers) {
          setLoadingMessage('Querying ' + server.address);
          await server.refresh();
        }

        setServerData(servers);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  if (error) return <div><b>Error</b>: {error}</div>;

  if (loading) return <div><i>{loadingMessage}</i></div>;

  return (
    <table>
      <thead>
        <tr>
          <th>Status</th>
          <th>Address:Port</th>
          <th>Name</th>
          <th>Language</th>
          <th>Links</th>
        </tr>
      </thead>
      <tbody>
        {serverData.map((server, index) => (
          <tr key={index}>
            <td style={{textAlign: 'center', color: server.online === null ? 'gray' : server.online ? 'green' : 'red' }}>
              {server.online === null ? 'Unknown' : server.online ? 'Online' : 'Offline'}
            </td>
            <td><a href={`samp://${server.address}`}>{server.address}</a></td>
            <td>{server.name}</td>
            <td>{server.language}</td>
            <td>
              {processLinks(server.links)}
              {server.linksUnavailable && <span> Links unavailable</span>}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export default ServersTable;