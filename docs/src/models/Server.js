class Server {
	constructor({ address, name, language, links, online }) {
		this.online   = online || null;
		this.address  = address;
		this.name     = name;
		this.language = language;
		this.links    = links;
	}

	async getInfo() {
		const [address, port] = this.address.split(':');

		try {
			const response = await fetch(`https://flaviopereira.dev/samp.php?host=${address}&port=${port}&opcodes=i`);
			const query    = await response.json();

			const i = query.info;

			if (i.length) {
				this.online   = true;
				this.name     = i.hostname;
				this.language = i.language;
			} else
				this.online = false;

			return true;
		} catch (error) {
			console.error('Error retrieving server info:', error);
			return false;
		}
	}

	async getLinks() {
		const [address, port] = this.address.split(':');

		try {
			const response = await fetch(`https://flaviopereira.dev/samp.php?host=${address}&port=${port}&opcodes=r`);
			const query    = await response.json();
	
			const r = query.rules;

			console.log(r);
	
			if (!r.length) false;
			
			this.links = Object.entries(r).filter(([key, value]) => key.startsWith('http')).map(([key, value]) => ({ key, value }));

			return true;
		} catch (error) {
			console.error('Error retrieving server rules:', error);
			return false;
		}
    }
}

export default Server;