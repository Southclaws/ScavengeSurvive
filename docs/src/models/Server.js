const QUERY_API = 'https://flaviopereira.dev/samp.php';

class Server {
  constructor({ address, name, language, links, online }) {
    this.online   = online || null;
    this.address  = address;
    this.name     = name;
    this.language = language;
    this.links    = links;
  }

  async ping() {
    const [address, port] = this.address.split(':');

    try {
      const url      = `${QUERY_API}?host=${address}&port=${port}&opcodes=p`;
      const response = await fetch(url);
      const query    = await response.json();

      this.online = query.online;

      return query.online; // yes, it just returns this boolean property
    } catch (error) {
      console.error('Error checking server status:', error);
    }

    return;
  }

  /**
    * Retrieves server "metadata".
    * @returns {boolean|null} Returns true if the server is online, false if it's offline, or null if there was an error retrieving the information.
    */
  async getInfo() {
    const [address, port] = this.address.split(':');

    try {
      const url      = `${QUERY_API}?host=${address}&port=${port}&opcodes=i`;
      const response = await fetch(url);
      const query    = await response.json();

      const i = query.info;

      this.online = Object.keys(i).length > 0;

      if (this.online) {
        this.name = i.hostname;
        if (i.language) this.language = i.language;
      }
      
      return this.online;
    } catch (error) {
      console.error('Error retrieving server info:', error);
    }

    return;
  }

  /**
   * Retrieves the links from the server.
   * @returns {boolean|null} Returns `true` if the links are successfully retrieved, `false` if there are no rules, or `null` if there is an error.
   */
  async getLinks() {
    const [address, port] = this.address.split(':');

    try {
      const url      = `${QUERY_API}?host=${address}&port=${port}&opcodes=r`;
      const response = await fetch(url);
      const query    = await response.json();

      const r = query.rules;

      if (Object.keys(r).length === 0) return false;

      // Scan for the presence of links in the rules payload, since servers can have custom rules
      this.links = Object.fromEntries(Object.entries(r).filter(([key, value]) => {
        // Accept if the key is 'weburl', since it's the native website thing
        if (key === 'weburl') return true;
        else if (value.match(/^(?:[a-z0-9]+(?:[a-z0-9-]*[a-z0-9]+)?\.)+[a-z]{2,}(?:\/.*)?$/i)) return true; // 'domain.tld/path'
      }));

      // Scan the links and add the http protocol if it's missing
      for (const [key, value] of Object.entries(this.links)) {
        if (!value.match(/^http/i))
          this.links[key] = `http://${value}`;
      }

      return true;
    } catch (error) {
      console.error('Error retrieving server rules:', error);
    }

    return;
  }
}

export default Server;