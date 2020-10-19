module.exports = {
  title: "Scavenge and Survive",
  tagline:
    "A PvP survival game where everyone is pitched against each other. Supplies are scarce and everyone is willing to kill for the same goals! Safety in numbers is key to survival, but trust is hard to find.",
  url: "https://scavengesurvive.com",
  baseUrl: "/",
  onBrokenLinks: "throw",
  favicon: "img/favicon.ico",
  organizationName: "Southclaws",
  projectName: "ScavengeSurvive",
  themeConfig: {
    colorMode: {
      defaultMode: "dark",
      disableSwitch: true,
    },
    navbar: {
      title: "Scavenge and Survive",
      logo: {
        alt: "Scavenge and Survive Logo",
        src: "img/SS-Logo-Hamm-2000.png",
      },
      items: [
        {
          to: "docs/",
          activeBasePath: "docs",
          label: "Docs",
          position: "left",
        },
        {
          href: "https://github.com/Southclaws/ScavengeSurvive",
          label: "GitHub",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [],
      copyright: `Copyright © ${new Date().getFullYear()} Barnaby "Southclaws" Keene - Built with Docusaurus.`,
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          editUrl:
            "https://github.com/Southclaws/ScavengeSurvive/edit/master/website/",
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      },
    ],
  ],
};
