const SERVERS_API = 'https://api.open.mp/servers';

class Server {
  constructor({ address, name, language, links, online }) {
    this.online   = online ?? null;
    this.address  = address;
    this.name     = name;
    this.language = language;
    this.links    = links;
    this.linksUnavailable = false;
  }

  // open.mp provides both metadata (core) and query rules (ru) in one response.
  async refresh() {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);

    try {
      const response = await fetch(`${SERVERS_API}/${encodeURI(this.address)}`, {
        signal: controller.signal,
      });
      if (!response.ok) throw new Error(`Server lookup returned HTTP ${response.status}`);

      const query = await response.json();
      if (!query.core || typeof query.core.hn !== 'string') {
        throw new Error('Server lookup did not return metadata');
      }

      this.online = true;
      this.name = query.core.hn;
      if (query.core.la) this.language = query.core.la;
      this.linksUnavailable = !query.ru || typeof query.ru !== 'object' || Array.isArray(query.ru);
      if (this.linksUnavailable) return;

      // Keep manually supplied links when the rules do not include them.
      const links = { ...this.links };
      for (const [key, value] of Object.entries(query.ru)) {
        if (typeof value !== 'string') continue;
        const candidate = value.trim();
        if (key !== 'weburl' && !/^(?:https?:\/\/)?(?:[a-z0-9-]+\.)+[a-z]{2,}(?:[/:?#].*)?$/i.test(candidate)) continue;
        if (!candidate) continue;

        try {
          const url = new URL(/^[a-z][a-z0-9+.-]*:/i.test(candidate) ? candidate : `https://${candidate}`);
          if (url.protocol === 'http:' || url.protocol === 'https:') links[key] = url.href;
        } catch (_) {
          // Ignore malformed rule values so the rest of the directory still renders.
        }
      }
      this.links = links;
    } catch (error) {
      this.online = null;
      this.linksUnavailable = true;
      console.error(`Error retrieving server details for ${this.address}:`, error);
    } finally {
      clearTimeout(timeout);
    }
  }
}

export default Server;
