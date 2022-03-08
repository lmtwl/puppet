#include <stdio.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <xtables.h>
#include <syslog.h>
#include <limits.h> /* INT_MAX in ip_tables.h */
#include <linux/netfilter_ipv4/ip_tables.h>
#include <linux/netfilter/nf_nat.h>

#ifndef NF_NAT_RANGE_PROTO_RANDOM_FULLY
#define NF_NAT_RANGE_PROTO_RANDOM_FULLY (1 << 4)
#endif

enum {
	O_TO_PORTS = 0,
	O_RANDOM,
	O_RANDOM_FULLY,
};

static void FULLCONENAT_help(void)
{
	printf(
	"FULLCONENAT target options:\n"
	" --to-ports <port>[-<port>]\n"
	"				Port (range) to map to.\n"
	" --random\n"
	"				Randomize source port.\n"
	" --random-fully\n"
	"				Fully randomize source port.\n");
}

static const struct xt_option_entry FULLCONENAT_opts[] = {
	{.name = "to-ports", .id = O_TO_PORTS, .type = XTTYPE_STRING},
	{.name = "random", .id = O_RANDOM, .type = XTTYPE_NONE},
	{.name = "random-fully", .id = O_RANDOM_FULLY, .type = XTTYPE_NONE},
	XTOPT_TABLEEND,
};

static void FULLCONENAT_init(struct xt_entry_target *t)
{
	struct nf_nat_ipv4_multi_range_compat *mr = (struct nf_nat_ipv4_multi_range_compat *)t->data;

	/* Actually, it's 0, but it's ignored at the moment. */
	mr->rangesize = 1;
}

/* Parses ports */
static void parse_ports(const char *arg, struct nf_nat_ipv4_multi_range_compat *mr)
{
	char *end;
	unsigned int port, maxport;

	mr->range[0].flags |= NF_NAT_RANGE_PROTO_SPECIFIED;

	if(!xtables_strtoui(arg, &end, &port, 0, UINT16_MAX))
	xtables_param_act(XTF_BAD_VALUE, "FULLCONENAT", "--to-ports", arg);

	switch(*end)
	{
		case '\0':
			mr->range[0].min.tcp.port = mr->range[0].max.tcp.port = htons(port);
			return;
		case '-':
			if(!xtables_strtoui(end + 1, NULL, &maxport, 0, UINT16_MAX)) break;

			if(maxport < port) break;

			mr->range[0].min.tcp.port = htons(port);
			mr->range[0].max.tcp.port = htons(maxport);
			return;
		default:
			break;
	}
	xtables_param_act(XTF_BAD_VALUE, "FULLCONENAT", "--to-ports", arg);
}

static void FULLCONENAT_parse(struct xt_option_call *cb)
{
	const struct ipt_entry *entry = cb->xt_entry;
	int portok;
	struct nf_nat_ipv4_multi_range_compat *mr = cb->data;

	switch(entry->ip.proto)
	{
		case IPPROTO_TCP:
		case IPPROTO_UDP:
		case IPPROTO_SCTP:
		case IPPROTO_DCCP:
		case IPPROTO_ICMP:
			portok = 1;
			break;
		default:
			portok = 0;
			break;
	}
	syslog(LOG_INFO, "proto = %d.", entry->ip.proto);
	xtables_option_parse(cb);
	switch (cb->entry->id)
	{
		case O_TO_PORTS:
			if(!portok) xtables_error(PARAMETER_PROBLEM, "Need TCP, UDP, SCTP or DCCP with port specification");
			parse_ports(cb->arg, mr);
			break;
		case O_RANDOM:
			mr->range[0].flags |=  NF_NAT_RANGE_PROTO_RANDOM;
			break;
		case O_RANDOM_FULLY:
			mr->range[0].flags |=  NF_NAT_RANGE_PROTO_RANDOM_FULLY;
			break;
	}
}

static void FULLCONENAT_print(const void *ip, const struct xt_entry_target *target, int numeric)
{
	const struct nf_nat_ipv4_multi_range_compat *mr = (const void *)target->data;
	const struct nf_nat_ipv4_range *r = &mr->range[0];

	if(r->flags & NF_NAT_RANGE_PROTO_SPECIFIED)
	{
		syslog(LOG_INFO, "masq ports: %hu", ntohs(r->min.tcp.port));
		if(r->max.tcp.port != r->min.tcp.port) syslog(LOG_INFO, "-%hu", ntohs(r->max.tcp.port));
	}

	if(r->flags & NF_NAT_RANGE_PROTO_RANDOM) syslog(LOG_INFO, " random");

	if(r->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) syslog(LOG_INFO, " random-fully");
}

static void FULLCONENAT_save(const void *ip, const struct xt_entry_target *target)
{
	const struct nf_nat_ipv4_multi_range_compat *mr = (const void *)target->data;
	const struct nf_nat_ipv4_range *r = &mr->range[0];

	if(r->flags & NF_NAT_RANGE_PROTO_SPECIFIED)
	{
		syslog(LOG_INFO, " --to-ports %hu", ntohs(r->min.tcp.port));
		if(r->max.tcp.port != r->min.tcp.port) syslog(LOG_INFO, "-%hu", ntohs(r->max.tcp.port));
	}
	if(r->flags & NF_NAT_RANGE_PROTO_RANDOM) syslog(LOG_INFO, " --random");
	if(r->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY) syslog(LOG_INFO, " --random-fully");
}

static struct xtables_target fullconenat_tg_reg = {
	.name		= "FULLCONENAT",
	.version	= XTABLES_VERSION,
	.family		= NFPROTO_IPV4,
	.size		= XT_ALIGN(sizeof(struct nf_nat_ipv4_multi_range_compat)),
	.userspacesize	= XT_ALIGN(sizeof(struct nf_nat_ipv4_multi_range_compat)),
	.help		= FULLCONENAT_help,
	.init		= FULLCONENAT_init,
	.x6_parse	= FULLCONENAT_parse,
	.print		= FULLCONENAT_print,
	.save		= FULLCONENAT_save,
	.x6_options	= FULLCONENAT_opts,
};

void _init(void)
{
	xtables_register_target(&fullconenat_tg_reg);
}
