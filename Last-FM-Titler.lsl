/**
 * This is free and unencumbered software released into the public domain.
 * 
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 * 
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * For more information, please refer to <http://unlicense.org/>
 */

string previous;
key request = "unknown";
float alpha = 1.0;
vector colour = <0.6, 0.6, 0.6>;
string title;
string text;
integer ticks;
integer scroll = 1;
string scrolled;
string unscrolled;

default
{
    state_entry()
    {
        colour = llGetColor(0);
        alpha = llGetAlpha(0);
        request = llHTTPRequest("http://ws.audioscrobbler.com/1.0/user/"+llGetObjectDesc()+"/recenttracks.txt", [HTTP_MIMETYPE, "text/plain;charset=utf-8"], "");
    }

    on_rez(integer _shit)
    {
        if(llGetAttached())
        {
            llSetTexture("8dcd4a48-2d37-4909-9f78-f7a9eb4ef903", -1);
            llSetLinkPrimitiveParamsFast(1, [PRIM_SIZE, <0.01, 0.01, 0.01>, PRIM_GLOW, -1, 0.0]);
            llSetLinkPrimitiveParamsFast(2, [PRIM_SIZE, <0.01, 0.01, 0.01>]);
        }
        else
        {
            llSetTexture("bce86e9a-dbbf-8bc7-48d2-fc3173ada377", -1);
            llSetLinkPrimitiveParamsFast(1, [PRIM_SIZE, <0.25, 0.25, 0.25>, PRIM_GLOW, -1, 0.1]);
            llSetLinkPrimitiveParamsFast(2, [PRIM_SIZE, <0.25, 0.25, 0.25>]);
        }

        llResetScript();
    }

    changed(integer _change)
    {
        if(_change & CHANGED_COLOR)
        {
            colour = llGetColor(0);
            alpha = llGetAlpha(0);

            if(title != "") llSetText("♬  [ "+title+" ]\n↕", colour, alpha);
        }
        else if(_change & CHANGED_TELEPORT) llResetScript();
    }

    http_response(key _id, integer _status, list _meta, string _data)
    {
        if(_data != previous && _id == request)
        {
            llSetTimerEvent(0.0);

            previous = _data;
            
            if(llGetObjectDesc() == "Replace this description/text with your Last.fm username.")
            {
                text = "Setup this attachments description!";
            }
            else text = llGetSubString(_data, llSubStringIndex(_data, ",") + 1, llSubStringIndex(_data, "\n") - 1);

            integer length = llStringLength(text);

            title = " ";

            if(length < 22) do title += "  "; while((--length) >= 0);
            else title = "                                          ";

            llSetText("♬  [ " + title + " ]\n↕", colour, alpha);

            if(length < 22)
            {
                scroll = 0;

                llSetLinkPrimitiveParamsFast(2, [PRIM_TEXT, "     " + text + "\n ", <1.0, 1.0, 1.0>, alpha]);
                llSleep(10.0);

                request = llHTTPRequest("http://ws.audioscrobbler.com/1.0/user/"+llGetObjectDesc()+"/recenttracks.txt", [HTTP_MIMETYPE, "text/plain;charset=utf-8"], "");

                llSetTimerEvent(0.2);

                return;
            }

            scroll = 1;

            llSetTimerEvent(0.2);
        }
    }

    timer()
    {
        if((++ticks) > 50)
        {
            llSetTimerEvent(5.0);

            ticks = 0;
            request = llHTTPRequest("http://ws.audioscrobbler.com/1.0/user/"+llGetObjectDesc()+"/recenttracks.txt", [HTTP_MIMETYPE, "text/plain;charset=utf-8"], "");
        }

        if(scroll)
        {
            if(unscrolled != text)
            {
                unscrolled = text;
                scrolled = text + "  //  ";
            }

            scrolled = llGetSubString(scrolled, 1, -1) + llGetSubString(scrolled, 0, 0);

            llSetLinkPrimitiveParamsFast(2, [PRIM_TEXT, "     " + llGetSubString(scrolled, 0, 25) + "\n ", <1.0, 1.0, 1.0>, alpha]);
            llSetTimerEvent(0.2);
        }
        else
        {
            llSetTimerEvent(0.0);
            llSetLinkPrimitiveParamsFast(2, [PRIM_TEXT, "                   " + text + "\n ", <1.0, 1.0, 1.0>, alpha]);
            llSleep(5.0);

            request = llHTTPRequest("http://ws.audioscrobbler.com/1.0/user/" + llGetObjectDesc() + "/recenttracks.txt", [HTTP_MIMETYPE, "text/plain;charset=utf-8"], "");
        }
    }
}
