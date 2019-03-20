import React from 'react';
import { shallow } from 'enzyme';
// import TestRenderer from 'react-test-renderer';
import SlideshowList from 'packs/postgame/SlideshowList';
import {mock_games_show_request_for_last_postgame} from '../fixtures/mocks/responses/mock_games_show_request_for_last_postgame';


describe('SlideshowList component', () => {
  it("3 Slideshow components will be created with correct params", () => {
     const current_postgame_id = mock_games_show_request_for_last_postgame.PostGameTab.current_postgame_id
     const decks_from_current_postgame = mock_games_show_request_for_last_postgame.PostGameTab.storage_of_viewed_postgames[current_postgame_id];

     const props = { arr_of_decks_of_cards: decks_from_current_postgame,
                     current_user_info: mock_games_show_request_for_last_postgame.current_user_info }



    const slideshow_component = shallow(<SlideshowList {...props} />);
    expect(slideshow_component.find('Slideshow').length).toEqual(3);

    const current_user_info = {};
    current_user_info.current_user_info = props.current_user_info;

    const slideshows = slideshow_component.find('Slideshow')
    // current_user_info = current_user_info.current_user_info;
    expect(slideshows.at(0).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[0] })
    expect(slideshows.at(1).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[1] })
    expect(slideshows.at(2).props()).toEqual({ ...current_user_info, deck: props.arr_of_decks_of_cards[2] })
  });
});
