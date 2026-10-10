import React from "react";
import { createRoot } from "react-dom/client";
import { MotionConfig, motion, useReducedMotion } from "framer-motion";
import {
  ArrowUpRight,
  ArrowRight,
  Plus,
  Check,
  Bell,
  Wallet,
  Layers,
  Search,
  Home,
  CalendarDays,
  Paperclip,
  LockKeyhole,
  Mic,
  ScanLine,
  Camera,
  Sparkles,
  Smartphone,
  Code2 as Github,
  Leaf,
  CheckCheck,
  ChevronLeft,
  FileText,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import "@fontsource/inter/latin-400.css";
import "@fontsource/inter/latin-500.css";
import "@fontsource/inter/latin-600.css";
import "@fontsource/manrope/latin-400.css";
import "@fontsource/manrope/latin-600.css";
import "@fontsource/manrope/latin-700.css";
import "@fontsource/manrope/latin-800.css";
import "./styles.css";

const MotionPreference = React.createContext(false);
function useMotionPreference() {
  const systemPreference = useReducedMotion();
  const manualPreference = React.useContext(MotionPreference);
  return systemPreference || manualPreference;
}
const base = import.meta.env.BASE_URL;
const repo = "https://github.com/nani-samireddy/later";
const path = window.location.pathname.replace(/\/+$/, "");
const page = path.endsWith("/privacy-policy")
  ? "privacy"
  : path.endsWith("/terms-and-conditions")
    ? "terms"
    : "home";
function Brand() {
  return (
    <a className="brand" href={base} aria-label="Later home">
      <span className="brand-icon">
        L<span />
      </span>
      later<span className="brand-period">.</span>
    </a>
  );
}
function Header() {
  return (
    <header className="header wrap">
      <Brand />
      <nav aria-label="Main navigation">
        <a href={`${base}#features`}>Features</a>
        <a href={`${base}#privacy`}>Your space</a>
        <a className="nav-cta" href={`${base}#download`}>
          Get Later <ArrowUpRight size={15} />
        </a>
      </nav>
    </header>
  );
}
function Reveal({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  const reduce = useMotionPreference();
  return (
    <motion.div
      className={className}
      initial={reduce ? false : { opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, amount: 0.12 }}
      transition={{ duration: 0.65, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}
function Tag({ children }: { children: React.ReactNode }) {
  return <span className="eyebrow">{children}</span>;
}
function IconTile({
  icon: Icon,
  tone = "orange",
}: {
  icon: LucideIcon;
  tone?: string;
}) {
  return (
    <span className={`icon-tile ${tone}`}>
      <Icon size={21} strokeWidth={1.7} />
    </span>
  );
}
function AppMockup() {
  return (
    <div
      className="phone"
      role="img"
      aria-label="Illustrative Later app preview: a thing, money summaries, and upcoming reminders. Sample data, not an actual screenshot."
    >
      <div className="phone-top">
        <b>9:41</b>
        <span>••• ▰</span>
      </div>
      <div className="app-head">
        <span className="tiny-brand">later.</span>
        <span className="avatar">S</span>
      </div>
      <p className="app-greeting">A little space for your day</p>
      <h3>
        Hey, Sam <span>✳</span>
      </h3>
      <div className="app-tabs">
        <span className="selected">Overview</span>
        <span>Things</span>
        <span>Money</span>
      </div>
      <div className="app-section">
        <b>Your things</b>
        <span>
          View all <ArrowRight size={10} />
        </span>
      </div>
      <div className="app-item">
        <IconTile icon={Leaf} tone="green" />
        <div>
          <b>Water the balcony plants</b>
          <span>Tomorrow, 8:00 AM</span>
        </div>
        <span className="check-circle" />
      </div>
      <div className="app-item">
        <IconTile icon={FileText} tone="purple" />
        <div>
          <b>Passport renewal</b>
          <span>
            <Paperclip size={10} /> 2 attachments
          </span>
        </div>
        <span className="check-circle" />
      </div>
      <div className="app-section">
        <b>A little money clarity</b>
        <span>
          <ArrowUpRight size={12} />
        </span>
      </div>
      <div className="money-grid">
        <div>
          <span>Owed to you</span>
          <b>
            ₹2,400<span>.00</span>
          </b>
          <small>Room for a gentle nudge</small>
        </div>
        <div>
          <span>You owe</span>
          <b>
            ₹850<span>.00</span>
          </b>
          <small>All in one place</small>
        </div>
      </div>
      <div className="app-section">
        <b>Coming up</b>
        <span>
          <CalendarDays size={12} />
        </span>
      </div>
      <div className="app-reminder">
        <span className="date-box">
          OCT<b>12</b>
        </span>
        <div>
          <b>Return Alex’s book</b>
          <span>Monday · 6:00 PM</span>
        </div>
        <Bell size={15} />
      </div>
      <div className="app-add">
        <Plus size={15} /> Add something
      </div>
      <div className="app-bottom">
        <Home size={18} />
        <Search size={18} />
        <CalendarDays size={18} />
        <span className="mini-avatar" />
      </div>
      <div className="home-bar" />
    </div>
  );
}
function Hero() {
  const reduce = useMotionPreference();
  return (
    <section className="hero wrap">
      <Reveal className="hero-copy">
        <Tag>
          <span className="status-dot" /> A SMALL APP FOR THE EVERYDAY
        </Tag>
        <h1>
          Life’s little things.
          <br />
          Off your{" "}
          <span className="hand-mark">
            mind.
            <svg viewBox="0 0 320 16" aria-hidden="true">
              <path d="M4 10 Q150 -3 314 9 M40 15 Q165 4 265 12" />
            </svg>
          </span>
        </h1>
        <p>
          The thing to do. The money to settle. The reminder you keep
          forgetting. Give it all a home in Later.
        </p>
        <a className="button primary" href="#download">
          Make room for later <ArrowUpRight size={19} />
        </a>
        <div className="hero-note">
          <LockKeyhole size={14} /> On your device. In your control.
        </div>
      </Reveal>
      <div className="hero-visual">
        <div className="orbit orbit-one" />
        <div className="orbit orbit-two" />
        <div className="visual-glow" />
        <span className="spark spark-one">✳</span>
        <span className="spark spark-two">✧</span>
        <motion.div
          className="phone-stage"
          initial={reduce ? false : { opacity: 0, y: 35, rotate: 4 }}
          animate={{ opacity: 1, y: 0, rotate: -4 }}
          transition={{ duration: 0.9, ease: [0.22, 1, 0.36, 1] }}
        >
          <AppMockup />
        </motion.div>
        <motion.div
          className="floating-note note-one"
          initial={reduce ? false : { opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0, y: reduce ? 0 : [0, -7, 0] }}
          transition={{
            opacity: { delay: 0.6, duration: 0.5 },
            x: { delay: 0.6 },
            y: { duration: 6, repeat: Infinity, ease: "easeInOut" },
          }}
        >
          <span className="note-icon">
            <Check size={16} />
          </span>
          <div>
            Remembered.<small>Now you can let it go.</small>
          </div>
        </motion.div>
        <motion.div
          className="floating-note note-two"
          animate={{ y: reduce ? 0 : [0, 7, 0] }}
          transition={{ duration: 7, repeat: Infinity, ease: "easeInOut" }}
        >
          <Bell size={18} />
          <div>
            A little nudge<small>At just the right time.</small>
          </div>
        </motion.div>
        <span className="mockup-label">
          A peek at Later · illustrative preview
        </span>
      </div>
    </section>
  );
}
const pillars = [
  {
    icon: Layers,
    title: "For the things",
    text: "Ideas, errands, and everything in between.",
  },
  {
    icon: Wallet,
    title: "For the money",
    text: "What you spent. Who owes whom.",
  },
  {
    icon: Bell,
    title: "For the right moment",
    text: "Reminders that bring it back to you.",
  },
];
function Features() {
  return (
    <section id="features" className="features wrap">
      <Reveal className="section-heading">
        <Tag>LESS MENTAL TABS. MORE LIVING.</Tag>
        <h2>
          A place for the bits
          <br />
          that make up your day.
        </h2>
        <p>
          No elaborate system to maintain.
          <br />
          Just capture it, keep it, and come back to it.
        </p>
      </Reveal>
      <div className="feature-grid">
        <Reveal className="feature-card things-card">
          <div className="card-top">
            <IconTile icon={Layers} />
            <span>01 / THINGS</span>
          </div>
          <h3>
            Big ideas.
            <br />
            Tiny to-dos.
          </h3>
          <p>
            Keep things with notes, photos, and documents. Edit, complete, or
            archive them when life moves on.
          </p>
          <div className="things-stack">
            <div className="paper-card back-paper" />
            <div className="paper-card">
              <span className="paper-label">
                A LITTLE SOMETHING TO REMEMBER
              </span>
              <h4>The weekend list</h4>
              <div>
                <span className="mini-check done">
                  <Check size={10} />
                </span>{" "}
                Pick up the parcel
              </div>
              <div>
                <span className="mini-check" /> Book a dentist visit
              </div>
              <div>
                <span className="mini-check" /> Try that new pasta recipe
              </div>
              <span className="paper-attachment">
                <Paperclip size={12} /> Keep the details close
              </span>
            </div>
            <span className="sticker">
              one less
              <br />
              thing ✳
            </span>
          </div>
        </Reveal>
        <Reveal className="feature-card money-card">
          <div className="card-top">
            <IconTile icon={Wallet} tone="green" />
            <span>02 / MONEY</span>
          </div>
          <h3>
            Less awkward.
            <br />
            More clear.
          </h3>
          <p>
            Track spending, money you owe, and money owed to you. Keep totals by
            currency and record repayments.
          </p>
          <div className="money-demo">
            <div className="money-demo-head">
              <span>The dinner split</span>
              <span className="sample-pill">SAMPLE</span>
            </div>
            <div className="person-row">
              <span className="person-icon">A</span>
              <div>
                <b>Alex</b>
                <small>Owes you</small>
              </div>
              <b>₹1,200</b>
            </div>
            <div className="person-row">
              <span className="person-icon peach">M</span>
              <div>
                <b>Maya</b>
                <small>You owe</small>
              </div>
              <b>₹600</b>
            </div>
            <div className="settled">
              <CheckCheck size={15} /> Settled up. Feels good.
            </div>
          </div>
        </Reveal>
        <Reveal className="feature-card reminder-card">
          <div className="card-top">
            <IconTile icon={Bell} tone="purple" />
            <span>03 / REMINDERS</span>
          </div>
          <h3>
            Remember when
            <br />
            it matters.
          </h3>
          <p>
            Choose a time, add recurring reminders, and see what’s coming up. A
            gentle nudge, with your permission.
          </p>
          <div className="reminder-demo">
            <div className="mini-calendar">
              <span>YOUR WEEK, A LITTLE LIGHTER</span>
              <div>
                {["M", "T", "W", "T", "F", "S", "S"].map((d, i) => (
                  <span key={i}>
                    {d}
                    <b className={i === 2 ? "today" : ""}>{12 + i}</b>
                  </span>
                ))}
              </div>
            </div>
            <div className="notification">
              <span className="notification-logo">L.</span>
              <div>
                <small>LATER · NOW</small>
                <b>Call home</b>
                <p>A little time for what matters.</p>
              </div>
            </div>
            <span className="repeat-note">
              <CalendarDays size={13} /> Every Wednesday
            </span>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
function Capture() {
  const [active, setActive] = React.useState(0);
  const options = [
    {
      icon: Plus,
      name: "Type it",
      text: "A quick thought. A clear place to put it.",
      quote: "Pick up a new notebook",
      detail: "Add a title, a note, or an attachment. Keep it simple.",
    },
    {
      icon: Mic,
      name: "Say it",
      text: "Get a thought down while it’s fresh.",
      quote: "Remind me to return the book",
      detail:
        "Optional voice capture uses a downloaded speech model on your device.",
    },
    {
      icon: Camera,
      name: "Capture it",
      text: "Keep the context, not just the title.",
      quote: "Keep the receipt with the expense",
      detail:
        "Take a photo or attach a file. Optional OCR reads payment screenshots locally.",
    },
  ];
  const current = options[active];
  return (
    <section className="capture wrap">
      <Reveal className="capture-copy">
        <Tag>THOUGHT → SAVED</Tag>
        <h2>
          Catch it.
          <br />
          Then carry on.
        </h2>
        <p>
          Some days you type. Some days you talk. Sometimes a photo says enough.
        </p>
        <div
          className="capture-tabs"
          role="tablist"
          aria-label="Ways to capture"
        >
          {options.map((option, i) => (
            <button
              key={option.name}
              id={`capture-tab-${i}`}
              role="tab"
              aria-selected={active === i}
              aria-controls="capture-panel"
              tabIndex={active === i ? 0 : -1}
              onKeyDown={(e) => {
                if (
                  ["ArrowRight", "ArrowLeft", "Home", "End"].includes(e.key)
                ) {
                  e.preventDefault();
                  const next =
                    e.key === "Home"
                      ? 0
                      : e.key === "End"
                        ? 2
                        : (i + (e.key === "ArrowRight" ? 1 : 2)) % 3;
                  setActive(next);
                  document.getElementById(`capture-tab-${next}`)?.focus();
                }
              }}
              onClick={() => setActive(i)}
            >
              <option.icon size={17} />
              {option.name}
            </button>
          ))}
        </div>
        <p className="capture-fine">
          Voice models download once. Optional local AI can help turn input into
          a draft on supported devices. You review it before saving.
        </p>
      </Reveal>
      <Reveal className="capture-panel">
        <div
          id="capture-panel"
          role="tabpanel"
          aria-labelledby={`capture-tab-${active}`}
          tabIndex={0}
        >
          <div className="capture-window-bar">
            <span />
            <span />
            <span />
            <small>MAKE A LITTLE ROOM</small>
          </div>
          <div className="capture-window-body">
            <IconTile icon={current.icon} />
            <h3>{current.text}</h3>
            <div className="input-demo">
              {current.quote}
              <span className="cursor" />
            </div>
            <div className="input-tools">
              <span>
                <Paperclip size={15} />
                <Bell size={15} />
                <ScanLine size={15} />
              </span>
              <span className="save-demo">
                Save for later <ArrowRight size={14} />
              </span>
            </div>
            <p>
              <Sparkles size={14} />
              {current.detail}
            </p>
          </div>
        </div>
        <span className="capture-doodle">a thought, safely parked ↗</span>
      </Reveal>
    </section>
  );
}
function Privacy() {
  return (
    <section id="privacy" className="privacy-section">
      <div className="privacy-inner wrap">
        <Reveal className="privacy-visual">
          <div className="privacy-disc">
            <LockKeyhole size={65} strokeWidth={1.1} />
            <span className="disc-ring" />
            <span className="disc-ring ring-two" />
          </div>
          <span className="privacy-badge">
            <span className="status-dot" /> LOCAL BY DESIGN
          </span>
          <span className="privacy-flower">✳</span>
        </Reveal>
        <Reveal className="privacy-copy">
          <Tag>A PERSONAL APP SHOULD FEEL PERSONAL.</Tag>
          <h2>
            Your life.
            <br />
            Your little corner.
          </h2>
          <p>
            Your entries stay in a local database. Your attachments stay in
            private app storage. No account to create, no cloud sync to set up.
          </p>
          <ul>
            <li>
              <Check size={16} /> Everyday entries work offline
            </li>
            <li>
              <Check size={16} /> Optional voice, OCR, and AI process locally
            </li>
            <li>
              <Check size={16} /> Export and restore your own local backup
            </li>
          </ul>
          <a className="text-link" href={`${base}privacy-policy/`}>
            Read how your data is handled <ArrowUpRight size={17} />
          </a>
          <p className="privacy-footnote">
            Model downloads require internet access. Exported files, external
            viewers, and your device’s backup settings are under your control.
          </p>
        </Reveal>
      </div>
    </section>
  );
}
function Download() {
  return (
    <section id="download" className="download wrap">
      <Reveal>
        <Tag>A LITTLE LESS ON YOUR MIND.</Tag>
        <h2>Leave it with Later.</h2>
        <p>
          We’re making room for the everyday.
          <br />
          Later for Android and iOS is coming soon.
        </p>
        <div className="platforms">
          <div>
            <Smartphone size={24} />
            <span>
              Android<small>Coming soon</small>
            </span>
          </div>
          <div>
            <Smartphone size={24} />
            <span>
              iOS<small>Coming soon</small>
            </span>
          </div>
        </div>
        <span className="release-note">
          No public download yet. A release date hasn’t been announced.
        </span>
        <a
          className="text-link"
          href={repo}
          target="_blank"
          rel="noopener noreferrer"
        >
          <Github size={16} /> Follow the project <ArrowUpRight size={15} />
        </a>
      </Reveal>
      <span className="download-spark" aria-hidden="true">
        ✳
      </span>
    </section>
  );
}
function Footer({
  reduced,
  toggleMotion,
}: {
  reduced: boolean;
  toggleMotion: () => void;
}) {
  return (
    <footer className="footer wrap">
      <div>
        <Brand />
        <p>A little space for life’s little things.</p>
      </div>
      <div className="footer-links">
        <a href={`${base}privacy-policy/`}>Privacy policy</a>
        <a href={`${base}terms-and-conditions/`}>Terms & conditions</a>
        <a href={repo} target="_blank" rel="noopener noreferrer">
          GitHub <ArrowUpRight size={12} />
        </a>
      </div>
      <div className="footer-note">
        <span>Made for a lighter everyday.</span>
        <button
          className="motion-toggle"
          aria-pressed={reduced}
          onClick={toggleMotion}
        >
          Reduce motion {reduced ? "· On" : "· Off"}
        </button>
      </div>
    </footer>
  );
}
const privacySections = [
  [
    "What Later keeps on your device",
    "Later stores the things and money entries you create: titles, notes, amounts, currencies, debt and repayment details, statuses, and reminder schedules. These records use a local SQLite database. Preferences are kept locally. Photos and files you attach are copied into private app storage so the app can reopen them independently of the original file. Private storage is not a promise of encryption; your device security and operating system also matter.",
  ],
  [
    "How that information is used",
    "The app uses your records to display, search, filter, edit, archive, and delete entries, calculate money summaries, and schedule reminders you request. The implementation does not include a Later account system, cloud sync, advertising, or an analytics service. Entries are not sent to a Later backend for processing.",
  ],
  [
    "Camera, files, and notifications",
    "Camera access is used when you choose to take a photo. The system photo or file picker supplies the attachments you select; Later does not need unrestricted access to all your files. Notification permission allows scheduled local reminders. On Android, exact-alarm permission may be requested for precise scheduling. Reminder content may appear on your lock screen according to your device settings. You can change permissions in system settings. Opening an attachment in another app gives that viewer access to the selected file; the viewer’s privacy practices apply.",
  ],
  [
    "Optional voice capture",
    "Voice capture requests microphone access for the session you start. Audio is processed by an on-device speech recognizer after its model has been downloaded. The current voice implementation does not upload recordings for transcription or save a reusable recording as an attachment; recognized text is placed in an entry draft for you to review. Voice model availability, language support, and behavior depend on the device and app build.",
  ],
  [
    "Optional OCR and local AI",
    "When you choose to process a payment screenshot, OCR reads text locally using ML Kit. Optional local AI can extract structured draft details from text on supported devices. The model runs on the device; review extracted amounts, people, dates, and other details before saving. Manual entry remains available without AI. The current local AI runtime is not supported on iOS. Feature availability depends on the app build and platform.",
  ],
  [
    "Model downloads and network services",
    "Preparing voice or optional AI features may download model files from Hugging Face and its delivery infrastructure. Those services receive normal request information such as your IP address and the requested model URL; the model download does not include your entries, attachment contents, or voice audio. Models occupy local storage. Their providers’ privacy policies apply to those requests. Ordinary entry management does not require a model download.",
  ],
  [
    "Backup, restore, and device backups",
    "Local export creates a compressed backup containing records and attachment contents. It is not encrypted by Later. You choose where to save it; a folder managed by another service may sync it elsewhere. Keep backups secure and share them only deliberately. Restore replaces the current app records and attachments with the chosen backup and rebuilds reminders as permissions allow. Your operating system may also back up app data according to its configuration; this is separate from a Later cloud-sync service.",
  ],
  [
    "Retention and deletion",
    "Entries and attachments remain on the device until you remove them or clear app data. Archiving keeps a record; it does not delete it. App settings include a way to clear entry data and private attachments. Optional model files may need to be removed separately. Copies you exported, original photos or documents, files shared with another app, and operating-system backups are not erased by deleting an entry in Later. Uninstall behavior depends on your device and backup settings.",
  ],
  [
    "This website and external links",
    "This landing website does not collect entries, offer a signup form, or add analytics or advertising scripts. It serves its fonts locally and does not store a tracking cookie. GitHub Pages hosts the site and may process request information, including IP addresses, under GitHub’s privacy statement. Following GitHub or model-provider links subjects you to those sites’ policies.",
  ],
  [
    "Questions and changes",
    "This policy describes the repository implementation reviewed on 10 October 2026. If data handling changes, this page should be updated before the changed version is released. The project repository is the currently available public route for questions; GitHub submissions may be public, so do not include private records or attachments. A dedicated privacy contact must be supplied by the publisher before store submission.",
  ],
];
const termsSections = [
  [
    "About these terms",
    "These terms describe use of Later, a personal app for things, money records, and reminders, and this informational website. Later is in development; public Android and iOS downloads are not yet available here, and no release date is promised. Review these terms and the privacy policy before using an available build.",
  ],
  [
    "Your use and your records",
    "Use Later lawfully and only with content you are entitled to store or process. You retain rights to your own content. The app needs to read and manage the records and files you provide to perform the features you request. Keep your device secure, review entries, and maintain backups you can restore. No account or automatic Later cloud sync is provided.",
  ],
  [
    "Money entries are personal records",
    "Later records spending and money owed; it does not transfer funds, process payments, verify a debt, or provide financial, tax, or legal advice. Summaries depend on the information you enter. Amounts in different currencies are kept separate rather than treated as converted balances. Confirm transactions and repayments independently.",
  ],
  [
    "Reminders and optional processing",
    "Notifications depend on permissions, device settings, time-zone changes, operating-system scheduling, and device availability. Do not rely on Later as your sole reminder for critical obligations or emergencies. Voice recognition, OCR, and AI may produce incomplete or incorrect drafts. Check all extracted details before saving. Optional features require compatible hardware, storage, and, for model downloads, an internet connection.",
  ],
  [
    "Attachments, backups, and other services",
    "External document viewers, model downloads, GitHub, and any storage service you choose have their own terms and privacy practices. You are responsible for securing exported backups, which contain records and attachment contents and are not encrypted by Later. Restoring a backup replaces current app data. Deletion in Later does not delete separately exported or externally stored copies.",
  ],
  [
    "Availability and changes",
    "Features and supported platforms may change during development. The app and site are provided as available, without a guarantee of uninterrupted operation, error-free results, recovery of lost records, or delivery of every reminder. To the extent permitted by applicable law, no additional warranty is offered. These statements do not exclude mandatory consumer rights or responsibility that cannot lawfully be excluded.",
  ],
  [
    "Stopping use and updates to these terms",
    "You may stop using Later at any time. Export data you want to keep, remove app records as needed, and manage any device or external backup copies separately. Material changes to these terms should be reflected on this page before the corresponding release. This page was last reviewed on 10 October 2026.",
  ],
  [
    "Publisher and questions",
    "The project repository is the current public route for questions. Do not post sensitive financial records or attachments in public GitHub discussions or issues. Before store distribution, the publisher must identify the responsible person or entity, provide a dedicated contact route, and confirm any jurisdiction-specific terms. This website does not invent that identity or impose an unverified governing law.",
  ],
];
function Legal() {
  const privacy = page === "privacy";
  const sections = privacy ? privacySections : termsSections;
  React.useEffect(() => {
    document.title = `${privacy ? "Privacy policy" : "Terms & conditions"} — Later`;
    document
      .querySelector('meta[name="description"]')
      ?.setAttribute(
        "content",
        privacy
          ? "How Later handles local records, attachments, permissions, model downloads, and backups."
          : "Terms for Later’s personal records, reminders, optional local processing, and backups.",
      );
  }, [privacy]);
  return (
    <main id="main" className="legal wrap">
      <a className="text-link" href={base}>
        <ChevronLeft size={16} /> Back to Later
      </a>
      <Tag>
        {privacy
          ? "YOUR INFORMATION, IN PLAIN WORDS."
          : "THE EVERYDAY DETAILS."}
      </Tag>
      <h1>{privacy ? "Privacy policy" : "Terms & conditions"}</h1>
      <p className="legal-lead">
        {privacy
          ? "A personal app deserves a clear explanation of where your information goes."
          : "A few clear expectations for using Later."}
      </p>
      <div className="legal-meta">
        Last reviewed 10 October 2026 · Pre-release implementation
      </div>
      <div className="legal-layout">
        <aside>
          <nav aria-label="On this page">
            <b>ON THIS PAGE</b>
            {sections.map(([title], i) => (
              <a key={title} href={`#section-${i + 1}`}>
                {title}
              </a>
            ))}
          </nav>
        </aside>
        <article>
          <div className="legal-summary">
            <LockKeyhole size={23} />
            <p>
              {privacy
                ? "Your records and attachments are stored locally. Optional model downloads and services you choose can make network requests."
                : "Later helps you keep personal records. You remain in control of your entries, permissions, and backups."}
            </p>
          </div>
          {sections.map(([title, body], i) => (
            <section id={`section-${i + 1}`} key={title}>
              <h2>
                <span>{String(i + 1).padStart(2, "0")}</span>
                {title}
              </h2>
              <p>{body}</p>
              {privacy && i === 5 && (
                <p>
                  <a
                    href="https://huggingface.co/privacy"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Hugging Face privacy policy <ArrowUpRight size={12} />
                  </a>
                </p>
              )}
              {privacy && i === 8 && (
                <p>
                  <a
                    href="https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    GitHub privacy statement <ArrowUpRight size={12} />
                  </a>
                </p>
              )}
            </section>
          ))}
          <div className="legal-end">
            <a className="text-link" href={repo}>
              Project repository <ArrowUpRight size={15} />
            </a>
            <a
              className="text-link"
              href={`${base}${privacy ? "terms-and-conditions" : "privacy-policy"}/`}
            >
              {privacy ? "Terms & conditions" : "Privacy policy"}{" "}
              <ArrowRight size={15} />
            </a>
          </div>
        </article>
      </div>
    </main>
  );
}
function App() {
  const systemPreference = useReducedMotion();
  const [manualPreference, setManualPreference] = React.useState(false);
  const reduced = Boolean(systemPreference || manualPreference);
  return (
    <MotionPreference.Provider value={reduced}>
      <div data-reduce-motion={reduced}>
        <MotionConfig reducedMotion={reduced ? "always" : "user"}>
          <a className="skip-link" href="#main">
            Skip to content
          </a>
          <Header />
          {page === "home" ? (
            <main id="main">
              <Hero />
              <div className="pillar-strip wrap">
                {pillars.map(({ icon: Icon, title, text }) => (
                  <div key={title}>
                    <Icon size={22} strokeWidth={1.5} />
                    <span>
                      <b>{title}</b>
                      <small>{text}</small>
                    </span>
                  </div>
                ))}
              </div>
              <Features />
              <Capture />
              <Privacy />
              <Download />
            </main>
          ) : (
            <Legal />
          )}
          <Footer
            reduced={reduced}
            toggleMotion={() => setManualPreference(!manualPreference)}
          />
        </MotionConfig>
      </div>
    </MotionPreference.Provider>
  );
}
createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
