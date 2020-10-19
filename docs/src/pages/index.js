import React from "react";
import Layout from "@theme/Layout";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import styles from "./styles.module.css";

function Home() {
  const context = useDocusaurusContext();
  const { siteConfig = {} } = context;
  return (
    <Layout title={siteConfig.title} description={siteConfig.description}>
      <main>
        <div className={styles.container}>
          <h1>The Scavenge and Survive Game</h1>
          <p>
            Scavenge and Survive is a San Andreas Multiplayer server mod, a PvP
            survival game where everyone is pitched against each other. Supplies
            are scarce and everyone is willing to kill for the same goals!
            Safety in numbers is key to survival, but trust is hard to find.
          </p>
          <span className={styles.logos}>
            <img src="img/SS-Logo-Hamm-2000.png" />
            <img src="img/SS-Logo-Type-2000.png" />
          </span>
        </div>

        <section className={styles.bg1}>
          <h2>Scroll down for a quick overview...</h2>
        </section>

        <div className={styles.container}>
          <div className="row">
            <img src="img/f2-objective.jpg" />
            <img src="img/f3-survival.jpg" />
            <img src="img/f4-building.jpg" />
            <img src="img/f5-combat.jpg" />
            <img src="img/f6-crafting.jpg" />
          </div>
        </div>

        <div className="divider"></div>

        <section className={styles.bg2}>
          <h2>Videos</h2>
        </section>

        <div className={styles.container}>
          <div className="row">
            <iframe
              width="100%"
              height="320px"
              src="https://www.youtube.com/embed/eX2b6aGKOyY"
              frameborder="0"
              allowfullscreen
            ></iframe>
          </div>
          <div className="row">
            <iframe
              width="100%"
              height="320px"
              src="https://www.youtube.com/embed/dcnFvKxCe2Q"
              frameborder="0"
              allowfullscreen
            ></iframe>
          </div>
          <div className="row">
            <iframe
              width="100%"
              height="320px"
              src="https://www.youtube.com/embed/AEp1SnYke4U"
              frameborder="0"
              allowfullscreen
            ></iframe>
          </div>
        </div>
      </main>
    </Layout>
  );
}

export default Home;
