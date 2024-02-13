# ethereum-cl-proxy

This project is a high performance Swift Server Side Software.

A load balancer / proxy made for Ethereum PoS validators. Requests are forwarded to all configured CL (beacon chain) RPCs
and the majority response is sent back as the final response.

## Usage

Docker Image coming soon.

The following Environment Variables are required:

```
# Comma separated list of beacon node endpoints
BEACON_NODE_ENDPOINTS=http://host.docker.internal:5051,http://host.docker.internal:5052
```

If you pass `https` links, and the server supports http2, http2 will be used, which increases performance.
Do not bother if your CL runs locally though, as benefits of http2 on a local machine are negligible.

There are no command line options. All configuration options are passed as environment variables.

## Background

The proxy subscribes to all event streams of all configured CLs and emits all unique events of healthy nodes to the
subscribers (validators).

This proxy is currently only implementing the subset of the CL API that is needed for validators. It can be found
[here](https://ethereum.github.io/beacon-APIs/#/ValidatorRequiredApi).
Thus the proxy cannot be used as a load balancer for normal CL queries. It would also defeat the purpose of a
"load balancer" as load is not really balanced but rather amplified (requests are forwarded to all configured
CLs instead of a randomly selected one).

This proxy is optimized to maximize validator participation rate and accuracy.Not to decrease load on configured CLs.

To achieve the maximum performance, an odd number of CLs should be configured to guarantee that there will
always be a majority.

The below set of configured CLs and recommended hardware specs for the `ethereum-cl-proxy` specifically
is tested and works great. More than that is unnecessary and might even negatively impact performance.

| Number of CLs | CPUs | RAM  | Bandwidth   |
| ------------- | ---- | ---- | ----------- |
| 3             | 4    | 8GB  | 500M/500M   |
| 3             | 4    | 8GB  | 500M/500M   |
| 5             | 4    | 8GB  | 500M/500M   |
| 7             | 8    | 16GB | 1000M/1000M |
| 9             | 8    | 16GB | 1000M/1000M |
| 11            | 16   | 32GB | 2000M/2000M |

Please make sure to not mix up CLs of different chains. The proxy health checks and kicks out CLs when their Genesis
or current fork number don't match. But this is considered a fail state and should be manually resolved. Don't let the
proxy decide for you, instead use it as a warning to get your CL fixed (in case a fork happened).

## Supported CLs

As we implement the minimal required validator API, any conforming CL is required to work with this proxy
out of the box.

The below CLs have been tested and are known to work well, including any combination of them:

- [Lighthouse](https://github.com/sigp/lighthouse)
- [Teku](https://github.com/Consensys/teku)
- [Lodestar](https://github.com/ChainSafe/lodestar)

The same is true for validator clients using this proxy as their configured CL.
Any VC conforming to the spec should be compatible. The important aspect is
that the VC needs a local anti-slashing database. This proxy doesn't have logic to prevent same numbered blocks/slots
to be emitted twice, so your VC needs to keep track of what was signed.
THIS IS TRUE FOR ALL THE VCs MENTIONED BELOW, BUT PLEASE DYOR AS THINGS CAN CHANGE AND WE CANNOT GUARANTEE HOW
THIRD PARTY SOFTWARE FUNCTIONS.

- [Lighthouse](https://github.com/sigp/lighthouse)
- [Teku](https://github.com/Consensys/teku)
- [Lodestar](https://github.com/ChainSafe/lodestar)

If you tested the proxy with other CLs, feel free to open a PR and extend this list.

## Risks

As the proxy emits events of multiple sources, the likelihood of emitting reorgs increases. This means if your VC
malfunctions (corrupt anti-slashing db, bad logic, etc.), the probability of a slashing event increases vs a single
configured CL. This is highly unlikely, but to prevent slashing further you can use
[Web3Signer](https://docs.web3signer.consensys.io/) on top of your normal setup, to have 2 individual anti-slashing
databases.
You can read more about anti-slashing strategies [here](https://www.kiln.fi/post/ethereum-anti-slashing-strategies).

The proxy is still a single point of failure if it goes down, hence doesn't increase uptime in this sense.
A thing that works very well is to deploy this proxy with multiple replicas on a kubernetes cluster and distribute
load between those multiple replicas (best case in different zones / datacenters). That way, if a node or a datacenter
goes down, your validators won't be down. But please make sure to also distribute your configured CLs to multiple
datacenters.

## Benefits

Because multiple CLs event streams are combined, participation rate increases as a single node being a little behind
doesn't mean your VC won't get the block in time.

Similarly, inclusion delay will be reduced as your will likely always have at least one CL that emits blocks in time.

Vote accuracy might actually decrease if you don't configure your VC correctly. As multiple CLs means you will
receive blocks much faster, you might receive wrong chains more often than with a single CL.
To counter this you can set config params like the following for Teku VCs:

`--validators-early-attestations-enabled=false`

[See here](https://docs.teku.consensys.io/reference/cli#validators-early-attestations-enabled).

Using this approach, accuracy will stay the same or increase a little depending on your setup.
