# Argus Monitored Accounts

> Accounts watched by the Argus daily brief pipeline.
> Organized by tier — determines polling priority and relevance weighting.
> Last updated: 2026-04-24

---

## Tier 1 — Never Miss

These accounts produce high-density signal on Ethereum protocol, security, and ecosystem governance.
Every post is reviewed. Score threshold lowered to 6+ for this tier.

| Handle | Focus |
|---|---|
| VitalikButerin | Ethereum research, philosophy, public goods |
| karpathy | AI, neural networks, LLM architecture |
| koeppelmann | Gnosis ecosystem, DAOs, prediction markets |
| timbeiko | Ethereum core dev, EIP coordination |
| samczsun | Security research, MEV, incident response |
| gakonst | Ethereum infra, clients, research |
| superphiz | Ethereum staking, validators, decentralization |
| hudsonjameson | Ethereum core dev history, governance |

RSS base URL: https://rsshub.app/twitter/user/{handle}

---

## Tier 2 — High Signal

Strong signal-to-noise. Review all posts. Score threshold 7+.

| Handle | Focus |
|---|---|
| shivsakhuja | AI agents, crypto x AI intersection |
| echinstitute | Ethereum research institute, public goods |
| ethereumfndn | Ethereum Foundation announcements |
| AustinGriffiths | ETH public goods, Buidl Guidl, ReFi |
| cyrilXBT | DeFi, on-chain analytics |

RSS base URL: https://rsshub.app/twitter/user/{handle}

---

## Tier 3 — Ecosystem

Gnosis ecosystem, DAOs, and Donny's active network. Score threshold 7+.

| Handle | Focus |
|---|---|
| aboutcircles | Circles UBI protocol |
| GnosisDAO | Gnosis DAO governance |
| gnosischain | Gnosis Chain announcements |
| safe | Safe multisig, account abstraction |
| gnosisguild | Gnosis Guild tooling |
| cowswap | CoW Protocol, MEV protection |
| kylearojas | ReFi, crypto public goods |
| thedaofund | DAO funding, ecosystem grants |
| chaskin22 | Ethereum ecosystem |
| etheconomiczone | Ethereum economic research |

RSS base URL: https://rsshub.app/twitter/user/{handle}

---

## Notes

- RSS feeds are served by RSSHub at https://rsshub.app/twitter/user/USERNAME
- All handles are case-insensitive for RSS lookup
- If an RSS feed returns empty or 404, log and skip — do not break the pipeline
- Score relevance against: Ethereum protocol, DAOs, ReFi, AI agents, Donny's ETHis 2026 work

## Related Pages
- [[argus-brief-template.md]] — output format for daily briefs
- [[agent-build-order.md]] — Argus build context
- [[daily-brief-2026-04-23.md]] — example output brief
