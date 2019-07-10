const config            = require('config');
const SiteFactoryClient = require('./lib/site-factory-client')

const factoryConn = config.get('factoryConnection');

const client = new SiteFactoryClient({
  username: factoryConn.username,
  apikey: factoryConn.apikey,
  factoryHost: factoryConn.factoryHost
});

async function main() {
  try {
    const response = await client.domains.get(211);

    console.log(response);
  } catch (err) {
    console.error(err);
  }
}

main();
