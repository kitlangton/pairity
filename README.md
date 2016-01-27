# Pairity

## Installation

1. Clone this project.
2. `cd` into the `pairity` directory.
3. Run `rake install`.
4. Run `pairity`.
5. Follow the instructions to setup Google Sheets and Slack integrations.
6. Add people and then save your sheet (instructions below).

## Usage

### Generating Pairs

1. Select **Generate Pairs**
2. (Optional) Select **Nope a Pair**, if a you would like to regenerate the pairs without the selected pairing.
3. Select **Save & Slack** to save the pairings and post them to your slack channel.

### Adding People

1. Run `pairity` in the terminal.
2. Select **Edit People**.
3. Select **Add**.
4. Enter their names, separated by commas:

`Booba Khan, Fumbo Dango, Papa Trepé, Jane Smith`

5. Select **Save Changes**.

### Deleting People

1. Run `pairity` in the terminal.
1. Select **Edit People**.
2. Select **Remove**.
3. Choose the person from the list.
4. Select **Save Changes**

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pairity. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

