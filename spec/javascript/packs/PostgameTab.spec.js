import React from 'react';
import {shallow} from 'enzyme';
import PostGameTab from 'packs/postgame/TabBody/PostGameTab';
import { mock_games_show_request_for_last_postgame } from '../fixtures/mock_games_show_request_for_last_postgame';

// import enzymeSerializer from 'enzyme-to-json/serializer';
// expect.addSnapshotSerializer(enzymeSerializer)

describe('PostGameTab Component', () => {

  it('renders card title', () => {
    const mockRetrieveCardsForPostgame = jest.fn();
    const post_game_tab_props = {
                                  ...mock_games_show_request_for_last_postgame.PostGameTab,
                                  retrieveCardsForPostgame: mockRetrieveCardsForPostgame
                                }
    const post_game_tab_component = shallow(<PostGameTab {...post_game_tab_props } />);

    expect(post_game_tab_component.find('CardTitle').children().text()).toEqual('Post Game Results');
  })

  it('renders helpful information on screen', () => {
    const mockRetrieveCardsForPostgame = jest.fn();
    const post_game_tab_props = {
                                  ...mock_games_show_request_for_last_postgame.PostGameTab,
                                  retrieveCardsForPostgame: mockRetrieveCardsForPostgame
                                }
    const post_game_tab_component = shallow(<PostGameTab {...post_game_tab_props } />);
    expect(post_game_tab_component.find('p').text()).toEqual('( * cards with red text were made by you * )');
  })

  it('renders the GameSelector with correct props and a key', () => {
    const mockRetrieveCardsForPostgame = jest.fn();
    const post_game_tab_props = {
                                  ...mock_games_show_request_for_last_postgame.PostGameTab,
                                  retrieveCardsForPostgame: mockRetrieveCardsForPostgame
                                }
    const post_game_tab_component = shallow(<PostGameTab {...post_game_tab_props } />);

    const expected_game_selector_props = {
      all_postgames_of__current_user: mock_games_show_request_for_last_postgame.OutOfGameCardUploadTab.out_of_game_cards,
      current_postgame_id: mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id,
      retrieveCardsForPostgame: mockRetrieveCardsForPostgame,
    }

    const GameSelector = post_game_tab_component.find('GameSelector');
    expect(GameSelector.length).toEqual(1);
    expect(GameSelector.props()).toEqual(expected_game_selector_props);
  })

  it('creates the list of slideshows that receive the correct props ', () => {
    const mockRetrieveCardsForPostgame = jest.fn();

    const post_game_tab_props = {
                                  ...mock_games_show_request_for_last_postgame.PostGameTab,
                                  retrieveCardsForPostgame: mockRetrieveCardsForPostgame,
                                  current_user_info: { ...mock_games_show_request_for_last_postgame.current_user_info }
                                };

    const post_game_tab_component = shallow(<PostGameTab {...post_game_tab_props } />);
    let current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id;
    let arr_of_decks_of_cards = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];
    const expected_slideshow_list_props = {
                                            current_user_info: { ...mock_games_show_request_for_last_postgame.current_user_info },
                                            arr_of_decks_of_cards
                                          };

    const SlideshowList = post_game_tab_component.find('SlideshowList');
    expect(SlideshowList.length).toEqual(1);
    expect(SlideshowList.key()).toEqual('slideshow_list_7');
    expect(SlideshowList.props()).toEqual(expected_slideshow_list_props);
  })
});
