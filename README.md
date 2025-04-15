## Custom Financial Portfolio Management System:

Developed a full-stack financial portfolio management application in Ruby, leveraging Rack and Thin for a lightweight server.

#### Database Integration and Data Persistence:
- Designed and implemented a persistent data storage solution using Sequel with SQLite, including user balance tracking, trade history, and balance history.

#### Real-Time Market Data and Trading:

- Integrated real-time stock pricing by consuming external APIs (e.g., Alpha Vantage) with caching for live data updates.

- Implemented dynamic trade validation to ensure sufficient account balance for buy orders and adequate shares for sell orders.

#### Algorithmic Trading Strategies:

- Built a modular framework for algorithmic trading allowing users to choose and execute multiple basic strategies (e.g., random, momentum, mean reversion) on scheduled intervals.

#### Interactive User Interface:

- Created an advanced, responsive front-end using HTML, CSS (via Bootstrap), and JavaScript, featuring real-time charts (using Chart.js), portfolio performance tables, and a strategy selector.

#### Real-Time Chat Functionality:

- Developed a WebSocket-based chat application for real-time user communication and live presence indicators.

#### Secure Authentication and Session Management:

- Designed a secure user authentication system with registration and login using Rack sessions and environment variable configuration for sensitive information (via Dotenv).